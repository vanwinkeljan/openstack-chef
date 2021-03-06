#
# Cookbook Name:: nova
# Recipe:: common
#
# Copyright 2010, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

node.default['authorization']['sudo']['include_sudoers_d'] = true

include_recipe "apt"
include_recipe "sudo"

package "nova-common" do
  options "--force-yes -o Dpkg::Options::=\"--force-confdef\""
  action :install
end

directory "/etc/nova" do
  owner "root"
  group "root"
  mode 0755
  action :create
end

env_filter = " AND chef_environment:#{node.chef_environment}"

sql_connection = nil
if node[:nova][:mysql]
  Chef::Log.info("Using mysql")
  package "python-mysqldb"
  mysqls = nil

  unless Chef::Config[:solo]
    mysqls = search(:node, "recipes:nova\\:\\:mysql#{env_filter}")
  end
  if mysqls and mysqls[0]
    mysql = mysqls[0]
    Chef::Log.info("Mysql server found at #{mysql[:mysql][:bind_address]}")
  else
    mysql = node
    Chef::Log.info("Using local mysql at  #{mysql[:mysql][:bind_address]}")
  end
  sql_connection = "mysql://#{mysql[:nova][:db][:user]}:#{mysql[:nova][:db][:password]}@#{mysql[:mysql][:bind_address]}/#{mysql[:nova][:db][:database]}"
elsif node[:nova][:postgresql]
  Chef::Log.info("Using postgresql")
  postgresqls = nil

  unless Chef::Config[:solo]
    postgresqls = search(:node, "recipes:nova\\:\\:postgresql#{env_filter}")
  end
  if postgresqls and postgresqls[0]
    postgresql = postgresqls[0]
    Chef::Log.info("PostgreSQL server found at #{postgresql[:ipaddress]}")
  else
    postgresql = node
    Chef::Log.info("Using local PostgreSQL at #{postgresql[:ipaddress]}")
  end
  sql_connection = "postgresql://#{postgresql[:nova][:db][:user]}:#{postgresql[:nova][:db][:password]}@#{postgresql[:ipaddress]}/#{postgresql[:nova][:db][:database]}"
end

rabbits = nil
unless Chef::Config[:solo]
  rabbits = search(:node, "recipes:nova\\:\\:rabbit#{env_filter}")
end
if rabbits and rabbits[0]
  rabbit = rabbits[0]
  Chef::Log.info("Rabbit server found at #{rabbit[:rabbitmq][:address]}")
else
  rabbit = node
  Chef::Log.info("Using local rabbit at #{rabbit[:rabbitmq][:address]}")
end

# Locate glance api servers
unless Chef::Config[:solo]
  api_nodes = search(:node, "recipes:glance\\:\\:api#{env_filter}")
  glance_api_servers = []

  api_nodes.each do |api_node|
    ip = api_node[:glance][:my_ip]
    port = api_node[:glance][:api_bind_port]
    glance_api_servers.push("#{ip}:#{port}")
  end

  Chef::Log.info("Found #{glance_api_servers.count} Glance API server(s) [#{glance_api_servers.join(",")}]")

  if not glance_api_servers.empty?
    node.default[:nova][:glance_api_servers] = glance_api_servers.join(",")
  end
end

template node[:nova][:log_config] do
  source "logging.cnf.erb"
  owner "nova"
  group "nova"
  mode 0644
end

rabbit_settings = {
  :address => rabbit[:rabbitmq][:address],
  :port => rabbit[:rabbitmq][:port],
  :user => rabbit[:nova][:rabbit][:user],
  :password => rabbit[:nova][:rabbit][:password],
  :vhost => rabbit[:nova][:rabbit][:vhost]
}

template "/etc/nova/nova.conf" do
  source "nova.conf.erb"
  owner "root"
  group "root"
  mode 0644
  variables(
    :sql_connection => sql_connection,
    :rabbit_settings => rabbit_settings,
    :extra_config => node[:nova][:extra_config]
  )
end

include_recipe "nova::setup"

#sudo "nova" do
#  user "nova"
#  runas "root"
#  nopasswd true
#  commands ["#{node[:nova][:rootwrap]}"]
#end


