#
# Cookbook Name:: keystone 
# Recipe:: postgresql
#

Chef::Log.info("PostgreSQL recipe included")

package "python-psycopg2"

bash "postgresql-grant-keystone-user-privileges" do
  code <<-EOH
    echo "GRANT ALL ON DATABASE #{node[:keystone][:db][:database]} TO #{node[:keystone][:db][:user]}" | su - postgres -c psql
  EOH
  action :nothing
end

bash "postgresql-create-keystone-user" do
  code <<-EOH
    echo "CREATE USER #{node[:keystone][:db][:user]} WITH PASSWORD '#{node[:keystone][:db][:password]}'" | su - postgres -c psql
  EOH
  action :nothing
  notifies :run, "bash[postgresql-grant-keystone-user-privileges]", :immediately
end

bash "postgresql-create-keystone-db" do
  code <<-EOH
    echo "CREATE DATABASE #{node[:keystone][:db][:database]}" | su - postgres -c psql
  EOH
  notifies :run, "bash[postgresql-create-keystone-user]", :immediately
end

# save data so it can be found by search
unless Chef::Config[:solo]
  Chef::Log.info("Saving node data")
  node.save
end
