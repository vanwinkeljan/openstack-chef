#
# Cookbook Name:: horizon
# Recipe:: postgresql
#

Chef::Log.info("PostgreSQL recipe included")

package "python-psycopg2"

bash "postgresql-grant-horizon-user-privileges" do
  code <<-EOH
    echo "GRANT ALL ON DATABASE #{node[:horizon][:db][:database]} TO #{node[:horizon][:db][:user]}" | su - postgres -c psql
  EOH
  action :nothing
end

bash "postgresql-create-horizon-user" do
  code <<-EOH
    echo "CREATE USER #{node[:horizon][:db][:user]} WITH PASSWORD '#{node[:horizon][:db][:password]}'" | su - postgres -c psql
  EOH
  action :nothing
  notifies :run, "bash[postgresql-grant-horizon-privileges]", :immediately
end

bash "postgresql-create-horizon-db" do
  code <<-EOH
    echo "CREATE DATABASE #{node[:horizon][:db][:database]}" | su - postgres -c psql
  EOH
  notifies :run, "bash[postgresql-create-horizon-user]", :immediately
end

# save data so it can be found by search
unless Chef::Config[:solo]
  Chef::Log.info("Saving node data")
  node.save
end

