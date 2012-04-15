#
# Cookbook Name:: horizon
# Recipe:: mysql
#
# Copyright 2012, Jan Van Winkel
#
# All rights reserved - Do Not Redistribute
#

execute "mysql-install-horizon-privileges" do
  command "/usr/bin/mysql -u root -p#{node[:mysql][:server_root_password]} < /etc/mysql/horizon-grants.sql"
  action :nothing
end

node[:mysql][:bind_address] = node[:horizon][:my_ip]

Chef::Log.info("Mysql recipe included")

include_recipe "mysql::server"
require 'rubygems'
Gem.clear_paths
require 'mysql'

template "/etc/mysql/horizon-grants.sql" do
  path "/etc/mysql/horizon-grants.sql"
  source "grants.sql.erb"
  owner "root"
  group "root"
  mode "0600"
  variables(
    :user     => node[:horizon][:db][:user],
    :password => node[:horizon][:db][:password],
    :database => node[:horizon][:db][:database]
  )
  notifies :run, resources(:execute => "mysql-install-horizon-privileges"), :immediately
end

execute "create #{node[:horizon][:db][:database]} database" do
  command "/usr/bin/mysqladmin -u root -p#{node[:mysql][:server_root_password]} create #{node[:horizon][:db][:database]}"
  not_if do
    m = Mysql.new("localhost", "root", node[:mysql][:server_root_password])
    m.list_dbs.include?(node[:horizon][:db][:database])
  end
end

# save data so it can be found by search
unless Chef::Config[:solo]
  Chef::Log.info("Saving node data")
  node.save
end


