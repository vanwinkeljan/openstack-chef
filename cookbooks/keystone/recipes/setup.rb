#
# Cookbook Name:: keystone
# Recipe:: setup

execute "keystone-manage db_sync" do
  user "keystone"
end


directory "/tmp/keystone_setup" do
  owner "keystone"
  group "keystone"
  mode "0700"
  action :create
end

base_cmd = "/usr/bin/keystone \
              --token #{node[:keystone][:admin_token]} \
              --endpoint #{node[:keystone][:endpoints]["keystone"][:adminurl]}"

extract_id = "| grep \"id \" | cut -d \"|\" -f 3"

node[:keystone][:tenants].each do |name, data|
  execute "Create Tenant \"#{name}\"" do
    command "#{base_cmd} \
             tenant-create \
             --name '#{name}' \
             --description '#{data[:description]}' \
             --enabled 'true' \
             #{extract_id}  > /tmp/keystone_setup/tenant_#{name}_id "
    user 'keystone'
    not_if { File.exists?("/var/lib/keystone/setup_tenants") }
  end
end
execute "touch /var/lib/keystone/setup_tenants"

node[:keystone][:roles].each do |role|
  execute "Create Role #{role}" do
    command "#{base_cmd} \
             role-create --name '#{role}' \
             #{extract_id}  > /tmp/keystone_setup/role_#{role}_id "
    user 'keystone'
    not_if { File.exists?("/var/lib/keystone/setup_roles") }
  end
end
execute "touch /var/lib/keystone/setup_roles"

node[:keystone][:users].each do |name, data|
  execute "Create User \"#{name}\"" do
    command "#{base_cmd} \
             user-create \
             --name '#{name}' \
             --pass '#{data[:pass]}' \
             --tenant_id `cat /tmp/keystone_setup/tenant_#{data[:tenant]}_id` \
             --enabled 'true' \
             #{extract_id}  > /tmp/keystone_setup/user_#{name}_id "
    user 'keystone'
    not_if { File.exists?("/var/lib/keystone/setup_users") }
  end
  execute "Add Role \"#{data[:role]}\" to User \"#{name}\"" do
    command "#{base_cmd} \
             user-role-add \
             --user `cat /tmp/keystone_setup/user_#{name}_id` \
             --tenant_id `cat /tmp/keystone_setup/tenant_#{data[:tenant]}_id` \
             --role `cat /tmp/keystone_setup/role_#{data[:role]}_id`"
    user 'keystone'
    not_if { File.exists?("/var/lib/keystone/setup_users") }
  end
end
execute "touch /var/lib/keystone/setup_users"


node[:keystone][:services].each do |name,data|
  execute "Create Service \"#{name}\"" do
    command "#{base_cmd} \
             service-create \
             --name '#{name}' \
             --type '#{data[:type]}' \
             --description '#{data[:description]}' \
             #{extract_id}  > /tmp/keystone_setup/service_#{name}_id "
    user 'keystone'
    not_if { File.exists?("/var/lib/keystone/setup_services") }
  end
end
execute "touch /var/lib/keystone/setup_services"

node[:keystone][:endpoints].each do |name,data|
  execute "Create Endpoint \"#{name}\"" do
    command "#{base_cmd} \
             endpoint-create \
             --region '#{data[:region]}' \
             --service_id `cat /tmp/keystone_setup/service_#{data[:service]}_id` \
             --publicurl '#{data[:publicurl]}' \
             --adminurl '#{data[:adminurl]}' \
             --internalurl '#{data[:internalurl]}'"
    user 'keystone'
    not_if { File.exists?("/var/lib/keystone/setup_endpoints") }
  end
end
execute "touch /var/lib/keystone/setup_endpoints"


#directory "/tmp/keystone_setup" do
#  recursive true
#  action :delete
#end

