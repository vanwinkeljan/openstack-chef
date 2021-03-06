#
# Cookbook Name:: nova
# Recipe:: vagrant
#
# Copyright 2011, Anso Labs
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
include_recipe "apt"

%w{lvm2}.each do |pkg|
  package pkg do
    options "--force-yes"
  end
end

execute "truncate -s #{node[:nova][:vg_file_size]} /root/nova-volumes" do
  user "root"
  not_if { File.exists?("/root/nova-volumes/") }
end

execute "losetup /dev/loop0 /root/nova-volumes" do
  user "root"
  not_if "losetup -a | grep /dev/loop0 || vgs --noheadings -o name | grep nova-volumes"
end

execute "vgcreate nova-volumes /dev/loop0" do
  user "root"
  not_if "vgs --noheadings -o name | grep nova-volumes"
end
