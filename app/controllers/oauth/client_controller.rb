
class Oauth::ClientController < ApplicationController

  def login
    return render :nothing => true unless self.provider
    return render :text => 'Admins can not use oauth' if myself.client_user?

    self.provider.return_url = self.return_url
    redirect_to provider.authorize_url
  end

  def callback
    return :nothing => true unless self.provider
    return render :text => 'Admins can not use oauth' if myself.client_user?

    if self.provider.access_token(params) && self.oauth_user.id && ! self.oauth_user.end_user.client_user?
      self.oauth_user.update_data(self.provider)

      if (myself.editor? || self.oauth_user.end_user.editor?) && (myself.id != self.oauth_user.end_user_id)
        self.provider.clear_session
        flash[:notice] = 'Editors can not login using oauth'
        return redirect_to self.return_url
      end

      session[:oauth_logged_in] = true
      if  myself.id != self.oauth_user.end_user_id
        self.oauth_user.end_user.update_attribute(:lead_source,myself.source_user_id) if myself.source_user_id.present?
        process_login(self.oauth_user.end_user)
      end
    else
      flash[:notice] = 'OAuth login failed' 
    end

    redirect_to self.return_url
  end

  protected

  def provider
    @provider ||= OauthProvider::Base.provider(params[:provider], session)
  end

  def oauth_user
    @oauth_user ||= self.provider.push_oauth_user(myself)
  end

  def return_url
    return @return_url if @return_url

    @return_url = params[:url]
    @return_url = '/' if @return_url.nil? || ! (@return_url =~ /^\//)
    @return_url
  end
end
