#
# Cookbook Name:: keystone
# Recipe:: setup

execute "keystone-manage db_sync" do
  user "keystone"
end

setup_commands = node[:keystone][:setup_commands]
if setup_commands then
  setup_commands.each do |cmd|
    execute "/usr/bin/keystone --token #{node[:keystone][:admin_token]} --endpoint #{node[:keystone][:service_endpoint]} #{cmd}" do
      user 'keystone'
      not_if { File.exists?("/var/lib/keystone/setup") }
    end
  end
end

execute "touch /var/lib/keystone/setup"
