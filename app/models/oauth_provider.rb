
module OauthProvider

  class Base
    include HandlerActions

    attr_accessor :return_url

    def self.provider(name, session)
      info = self.get_handler_info(:oauth, :provider).find { |info| info[:name].downcase.underscore == name }
      info ? info[:class].new(session) : nil
    end

    def self.provider_options
      self.get_handler_info(:oauth, :provider).collect { |info| [info[:name], info[:name].downcase.underscore] }
    end

    def initialize(session={})
      @session = session
    end

    def info; @info ||= self.class.oauth_provider_handler_info; end
    def identifier; self.info[:identifier]; end
    def name; self.info[:name]; end
    def option_name; self.info[:name].downcase.underscore; end
    def session_name; "oauth_#{self.option_name}"; end
    def get_oauth_user_data; {}; end
    def get_profile_photo_url; nil; end

    def session
      @session[self.session_name] ||= {}
    end

    def clear_session
      @session[self.session_name] = nil
    end

    def token
      self.session[:token]
    end

    def token=(token)
      self.session[:token] = token
    end

    def logged_in?
      self.token ? true : false
    end

    def redirect_uri=(redirect_uri)
      @redirect_uri = redirect_uri
    end

    def redirect_uri
      @redirect_uri ||= Configuration.domain_link "/website/oauth/client/callback?provider=#{self.option_name}&url=#{CGI::escape(self.return_url)}"
    end

    def push_oauth_user(myself)
      @oauth_user ||= OauthUser.push_oauth_user(myself, self)
    end
  end
end
