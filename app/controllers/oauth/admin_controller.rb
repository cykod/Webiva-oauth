
class Oauth::AdminController < ModuleController

 component_info 'Oauth', :description => 'Oauth support', 
                              :access => :public
                              
 # Register a handler feature
 register_permission_category :oauth, "Oauth" ,"Permissions related to Oauth"
  
 register_permissions :oauth, [ [ :manage, 'Manage Oauth', 'Manage Oauth' ],
                                  [ :config, 'Configure Oauth', 'Configure Oauth' ]
                                  ]
 cms_admin_paths "options",
    "Oauth Options" => { :action => 'index' },
    "Options" => { :controller => '/options' },
    "Modules" => { :controller => '/modules' }

  register_handler :editor, :auth_login_feature, 'OauthLoginExtension'

 permit 'oauth_config'

 public 
 
 def options
    cms_page_path ['Options','Modules'],"Oauth Options"
    
    @options = self.class.module_options(params[:options])
    
    if request.post? && @options.valid?
      Configuration.set_config_model(@options)
      flash[:notice] = "Updated Oauth module options".t 
      redirect_to :controller => '/modules'
      return
    end    
  
  end
  
  def self.module_options(vals=nil)
    Configuration.get_config_model(Options,vals)
  end
  
  class Options < HashModel
   # Options attributes 
   # attributes :attribute_name => value
  
  end
  
end
