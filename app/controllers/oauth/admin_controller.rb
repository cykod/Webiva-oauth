
class Oauth::AdminController < ModuleController

 component_info 'Oauth', :description => 'Oauth support', 
                              :access => :private
                              
 # Register a handler feature
 register_permission_category :oauth, "Oauth" ,"Permissions related to Oauth"
  
 register_permissions :oauth, [ [ :manage, 'Manage Oauth', 'Manage Oauth' ],
                                  [ :config, 'Configure Oauth', 'Configure Oauth' ]
                                  ]

linked_models :end_user, [ :oauth_user ] 
 
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
    attributes :user_class_id => UserClass.default_user_class_id
  
    def validate
      cls = UserClass.find_by_id_and_editor(self.user_class_id,false)
      errors.add(:user_class_id,'is invalid') unless cls
    end

  end
  
end
