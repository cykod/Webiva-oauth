
class OauthUser < DomainModel
  has_end_user :end_user_id, :name_column => :name

  validates_presence_of :provider
  validates_presence_of :end_user_id
  validates_presence_of :provider_id

  named_scope :by_provider, lambda { |provider| {:conditions => {:provider => provider.option_name, :provider_id => provider.provider_id}} }

  def name
    if self.first_name && self.last_name
      "#{self.first_name} #{self.last_name}"
    elsif self.first_name
      self.first_name
    end
  end

  def self.push_oauth_user(myself, provider)
    return OauthUser.new if provider.provider_id.blank?

    user = OauthUser.by_provider(provider).find(:first)
    return user if user

    user = OauthUser.new :provider => provider.option_name, :provider_id => provider.provider_id
    user.push_end_user(myself)
    user.save
    user
  end

  def push_end_user(myself)
    unless myself.id
      opts = Oauth::AdminController.module_options
      if ! self.email.blank?
        myself = EndUser.push_target(self.email,:user_class_id => opts.user_class_id)
      else
        myself = EndUser.new
        myself.user_class_id = opts.user_class_id
        myself.admin_edit = true
      end


      if myself.id.nil? || ! myself.registered?

        myself.update_attributes :registered => true, :activated => true, :hashed_password => 'invalid'
      end
    end

    self.end_user_id = myself.id unless myself.client_user?
  end

  def update_data(provider)
    can_update_end_user = false
    if (self.end_user.first_name.blank? || self.end_user.first_name == self.first_name) &&
        (self.end_user.last_name.blank? || self.end_user.last_name == self.last_name)
      can_update_end_user = true
    end

    update_profile_photo = false
    photo_url = provider.get_profile_photo_url

    unless photo_url.blank?
      update_profile_photo = self.end_user.domain_file_id.nil? || self.profile_photo_url != photo_url
    end

    self.update_attributes provider.get_oauth_user_data

    if can_update_end_user
      self.end_user.email = self.email if self.end_user.email.blank?
      self.end_user.first_name = self.first_name
      self.end_user.last_name = self.last_name
      self.end_user.admin_edit = true if self.end_user.email.blank?
      self.end_user.save
    end

    self.end_user.run_worker(:run_update_profile_photo, :url => photo_url) if update_profile_photo
  end
end
