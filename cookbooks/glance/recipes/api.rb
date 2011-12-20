#
# Cookbook Name:: glance
# Recipe:: api
#
#

include_recipe "#{@cookbook_name}::common"

# Locate glance registry and retrieve it's IP
unless Chef::Config[:solo]
  registries = search(:node, "recipes:glance\\:\\:registry")
  if registries and registries[0]
    node.default[:glance][:registry_host] = registries[0][:glance][:registry_host]
  end
end

Chef::Log.info("Using glance registry at #{node[:glance][:registry_host]}")

cache = node[:glance][:cache] == "True" ? "cache" : ""
cachemanage = node[:glance][:cache_management] == "True" ? "cachemanage" : ""

template node[:glance][:api_config_file] do
  source "glance-api.conf.erb"
  owner "glance"
  group "root"
  mode 0644
  variables(
    :cache => cache,
    :cachemanage => cachemanage
  )
end

template node[:glance][:cache_config_file] do
  source "glance-cache.conf.erb"
  owner "glance"
  group "root"
  mode 0644
end

template node[:glance][:scrubber_config_file] do
  source "glance-scrubber.conf.erb"
  owner "glance"
  group "root"
  mode 0644
end

package "glance-api" do
  options "--force-yes -o Dpkg::Options::=\"--force-confdef\""
  action :install
end

service "glance-api" do
  if (platform?("ubuntu") && node.platform_version.to_f >= 10.04)
    restart_command "restart glance-api"
    stop_command "stop glance-api"
    start_command "start glance-api"
    status_command "status glance-api | cut -d' ' -f2 | cut -d'/' -f1 | grep start"
  end
  supports :status => true, :restart => true
  action :start
  subscribes :restart, resources(:template => node[:glance][:api_config_file])
  subscribes :restart, resources(:package => "glance-api")
end

file "/var/log/glance/api.log" do
  owner "glance"
  group "root"
  mode "0644"
  action :create
  notifies :restart, resources(:service => "glance-api"), :immediately
end

["", "incomplete", "invalid", "queue"].each do |cache_dir|

  directory "#{node[:glance][:image_cache_dir]}/#{cache_dir}" do
    owner "glance"
    group "root"
    mode "0755"
    action :create
  end

end
