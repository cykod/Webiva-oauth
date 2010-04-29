
class Oauth::ClientController < ApplicationController

  def login
    return :nothing => true unless self.provider
    return render :text => 'Editors can not use oauth' if myself.editor?

    self.provider.return_url = self.return_url
    redirect_to provider.authorize_url
  end

  def callback
    return :nothing => true unless self.provider
    return render :text => 'Editors can not use oauth' if myself.editor?

    if self.provider.access_token(params) && self.oauth_user.id && ! self.oauth_user.end_user.editor?
      self.oauth_user.update_data(self.provider)
      process_login self.oauth_user.end_user
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
