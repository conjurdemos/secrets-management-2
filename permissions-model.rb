require 'conjur/env'
config = {}
config[:env] = Conjur.env
config[:stack] = Conjur.stack
config[:account] = Conjur.account
keys = config[:api_keys]  = {}

# This model separates duties between 
namespace do
  config[:namespace] = namespace
  
  group "admin" do
    owns do
      # This is a service layer which performs provisioning operations
      provision_service = layer "provision" do |layer|
        # Create a host and add it to the layer
        host("a") do |a|
          keys[:host_a] = a.api_key
          layer.add_host a.roleid
        end
      end

      # This role can use the provisioning service 
      secrets_user = role "ops", "user" do |role|
        provision_service.resource.permit "execute", role.roleid

        # Create a user and grant him this role
        user("#{namespace}-bob") do |u|
          keys[:bob] = u.api_key
          role.grant_to u.roleid
        end
      end
      
      # This role can admin the infrastructure, including secrets
      role "ops", "admin" do |role|
        # Create a user and grant her this role
        user("#{namespace}-alice") do |u|
          keys[:alice] = u.api_key
          role.grant_to u.roleid
        end
        
        owns do
          web_tier = layer "web" do |layer|
            layer.role.grant_to provision_service.roleid, admin_option: true
          end
          app_tier = layer "app" do |layer|
            layer.role.grant_to provision_service.roleid, admin_option: true
          end

          secrets = environment "secrets" do |e|
            # Besides the role ops:admin, only the layers can read the secrets
            # The ops:user role can use the provisioning service, but cannot read the secrets
            add_member "use_variable",    web_tier.roleid
            add_member "use_variable",    app_tier.roleid
            
            # Put a db-password variable in the environment
            variable "secrets/db-password", mime_type: "text/plain", kind: "password" do |v|
              v.add_value "the-password"
              e.add_variable 'db-password', v.id
            end
          end
        end
      end
    end
  end
end

config.to_yaml