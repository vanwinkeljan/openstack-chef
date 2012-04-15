#
# Cookbook Name:: horizon
# Recipe:: default
#
# Copyright 2012, Jan Van Winkel
#
# All rights reserved - Do Not Redistribute
#

include_recipe "apache2"
include_recipe "apache2::mod_wsgi"

env_filter = ''
if node[:app_environment]
  env_filter = " AND app_environment:#{node[:app_environment]}"
end

# Find the database and extract settings
db = nil
if node[:horizon][:mysql]
  Chef::Log.info("Using mysql")
  package "python-mysqldb"
  mysqls = nil

  unless Chef::Config[:solo]
    mysqls = search(:node, "recipes:horizon\\:\\:mysql#{env_filter}")
  end
  if mysqls and mysqls[0]
    mysql = mysqls[0]
    Chef::Log.info("Mysql server found at #{mysql[:mysql][:bind_address]}")
  else
    mysql = node
    Chef::Log.info("Using local mysql at  #{mysql[:mysql][:bind_address]}")
  end

  db = { :user => mysql[:horizon][:db][:user],
         :name => mysql[:horizon][:db][:database],
         :pass => mysql[:horizon][:db][:password],
         :ip   => mysql[:mysql][:bind_address],
         :backend => "django.db.backends.mysql"
       }

elsif node[:horizon][:postgresql]
  Chef::Log.info("Using postgresql")
  postgresqls = nil

  unless Chef::Config[:solo]
    postgresqls = search(:node, "recipes:horizon\\:\\:postgresql#{env_filter}")
  end
  if postgresqls and postgresqls[0]
    postgresql = postgresqls[0]
    Chef::Log.info("PostgreSQL server found at #{postgresql[:ipaddress]}")
  else
    postgresql = node
    Chef::Log.info("Using local PostgreSQL at #{postgresql[:ipaddress]}")
  end
  
  db = { :user => postgresql[:horizon][:db][:user],
         :name => postgresql[:horizon][:db][:database],
         :pass => postgresql[:horizon][:db][:password],
         :ip   => postgresql[:ipaddress],
         :backend => "django.db.backends.postgresql"
       }
end

# Find keystone
keystone = nil

keystone_nodes = nil
unless Chef::Config[:solo]
  keystone_nodes = search(:node, "recipes:keystone\\:\\:mysql#{env_filter}")
end
if keystone_nodes and keystone_nodes[0]
  keystone_node = keystone_nodes[0]
  Chef::Log.info("Keystone server found at #{keystone_node[:keystone][:my_ip]}")
else
  keystone_node = node
  Chef::Log.info("Using local Keystone server at #{keystone_node[:keystone][:my_ip]}")
end

keystone = { :ip => keystone_node[:keystone][:my_ip],
             :endpoint => keystone_node[:keystone][:endpoints]["keystone"][:publicurl],
             :member => keystone_node[:keystone][:horizon][:member]
           }

#install and configure horizon
package "openstack-dashboard" do
  options "--force-yes -o Dpkg::Options::=\"--force-confdef\""
  action :install
end

template "/etc/openstack-dashboard/local_settings.py" do
  source "local_settings.py.erb"
  owner "root"
  group "root"
  mode 0644
  variables(
    :db => db,
    :keystone => keystone
  )
end


