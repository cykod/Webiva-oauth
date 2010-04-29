
class OauthLoginExtension < Handlers::ParagraphLoginExtension

  def self.editor_auth_login_feature_handler_info
    { 
      :name => 'OAuth Login Extension',
      :paragraph_options_partial => '/oauth/handler/auth_login'
    }
  end

  def logged_in(renderer, login_options)
    super

    if myself.id && session[:oauth_logged_in]
      if @options.access_token_id && ! myself.has_token?(@options.access_token_id)
        return redirect_paragraph :site_node => @options.edit_account_page_id
      elsif @login_options.forward_login == 'yes' && session[:lock_lockout]
        lock_logout = session[:lock_lockout]
        session[:lock_lockout] = nil
        return redirect_paragraph lock_logout
      elsif @login_options.destination_page_id
        return redirect_paragraph :site_node => @login_options.destination_page_id
      end
    end

    nil
  end

  # Adds any feature related tags
  def feature_tags(c, data)
    c.expansion_tag('oauth') { |t| true }

    url = CGI::escape @renderer.paragraph_page_url
    OauthProvider::Base.provider_options.each do |option|
      c.expansion_tag("oauth:#{option[1]}") { |t| true }
      c.link_tag("oauth:#{option[1]}:login") { |t| "/website/oauth/client/login?provider=#{option[1]}&url=#{url}" }
      c.value_tag("oauth:#{option[1]}:name") { |t| option[0] }
    end
  end

  # Paragraph Setup options
  def self.paragraph_options(val={})
    opts = LoginExtensionParagraphOptions.new(val)
  end

  class LoginExtensionParagraphOptions < HashModel
    attributes :access_token_id => nil, :edit_account_page_id => nil

    options_form(
                 fld(:access_token_id, :select, :options => :access_token_options, :label => 'Access Token'),
                 fld(:edit_account_page_id, :select, :options => :page_options, :label => 'Edit Account Page')                 
                 )

    def self.access_token_options
      [['--Select Access Token--', nil]] + AccessToken.user_token_options
    end

    def self.page_options
      [[ '--Stay on Same Page--'.t, nil ]] + SiteNode.page_options()
    end
  end
end
