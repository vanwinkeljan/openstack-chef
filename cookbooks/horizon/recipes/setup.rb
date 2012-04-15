#
# Cookbook Name:: horizon
# Recipe:: setup
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

execute "/usr/share/openstack-dashboard/manage.py syncdb" do
  action :run
end

