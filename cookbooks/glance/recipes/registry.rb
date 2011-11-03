#
# Cookbook Name:: glance
# Recipe:: registry
#
#

include_recipe "#{@cookbook_name}::common"

sql_connection = nil
if node[:glance][:mysql]
  Chef::Log.info("Using mysql")
  package "python-mysqldb"
  mysqls = nil

  unless Chef::Config[:solo]
    mysqls = search(:node, "recipes:glance\\:\\:mysql")
  end
  if mysqls and mysqls[0]
    mysql = mysqls[0]
    Chef::Log.info("Mysql server found at #{mysql[:mysql][:bind_address]}")
  else
    mysql = node
    Chef::Log.info("Using local mysql at  #{mysql[:mysql][:bind_address]}")
  end
  sql_connection = "mysql://#{mysql[:glance][:db][:user]}:#{mysql[:glance][:db][:password]}@#{mysql[:mysql][:bind_address]}/#{mysql[:glance][:db][:database]}"
elsif node[:glance][:postgresql]
  Chef::Log.info("Using postgresql")
  postgresqls = nil

  unless Chef::Config[:solo]
    postgresqls = search(:node, "recipes:glance\\:\\:postgresql")
  end
  if postgresqls and postgresqls[0]
    postgresql = postgresqls[0]
    Chef::Log.info("PostgreSQL server found at #{postgresql[:ipaddress]}")
  else
    postgresql = node
    Chef::Log.info("Using local PostgreSQL at #{postgresql[:ipaddress]}")
  end
  sql_connection = "postgresql://#{postgresql[:glance][:db][:user]}:#{postgresql[:glance][:db][:password]}@#{postgresql[:ipaddress]}/#{postgresql[:glance][:db][:database]}"
else
  # default to sqlite
  sql_connection = "sqlite:////var/lib/glance/glance.sqlite"
end

glance_service "registry"

template node[:glance][:registry_config_file] do
  source "glance-registry.conf.erb"
  owner "glance"
  group "root"
  mode 0644
  variables(
    :sql_connection => sql_connection
  )
  notifies :restart, resources(:service => "glance-registry"), :immediately
end
