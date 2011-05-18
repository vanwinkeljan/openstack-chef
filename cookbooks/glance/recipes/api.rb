#
# Cookbook Name:: glance
# Recipe:: api
#
#

include_recipe "#{@cookbook_name}::common"

template node[:glance][:api_config_file] do
  source "glance-api.conf.erb"
  owner "glance"
  group "root"
  mode 0644
end

file "/var/log/glance/api.log" do
  owner "glance"
  group "root"
  mode "0644"
  action :create
end

glance_service "api"
