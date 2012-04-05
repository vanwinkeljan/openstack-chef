#
# Cookbook Name:: iscsi
# Recipe:: default
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

package "iscsitarget" do
  action :install
end

package "iscsitarget-source" do
  action :install
end

package "iscsitarget" do
  action :install
end

package "iscsitarget-dkms" do
  action :install
end


