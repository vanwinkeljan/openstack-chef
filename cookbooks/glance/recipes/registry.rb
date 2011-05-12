#
# Cookbook Name:: glance
# Recipe:: registry
#
#

include_recipe "#{@cookbook_name}::common"

template node[:glance][:registry_config_file] do
  source "glance-registry.conf.erb"
  owner "glance"
  group "root"
  mode 0644
end

glance_service "registry"
