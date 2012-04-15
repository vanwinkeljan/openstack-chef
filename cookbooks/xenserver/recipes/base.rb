#
# Cookbook Name:: xenserver
# Recipe:: base
#
# Copyright 2011, Jan Van Winkel
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

include_recipe "apt"

apt_repository "xcp-unstable" do
  uri "http://ppa.launchpad.net/ubuntu-xen-org/xcp-unstable/ubuntu "
  distribution "precise"
  components ["main"]
  keyserver "keyserver.ubuntu.com"
  key "9273A937"
  apt_key_env node[:xenserver][:apt_key_env]
  action :add
  notifies :run, "execute[apt-get update]", :immediately
end

directory "/etc/xcp" do
  owner "root"
  group "root"
  mode "0755"
  action :create
end

directory "/usr/share/qemu" do
  owner "root"
  group "root"
  mode "0755"
  action :create
end

link "/usr/share/qemu/keymaps" do
  to "/usr/share/qemu-linaro/keymaps"
  owner "root"
  group "root"
end

file "/etc/xcp/network.conf" do
  owner "root"
  group "root"
  mode "0755"
  content "bridge"
  action :create
end

package "pciutils" do
  action :install
end

package "xcp-xapi" do
  action :install
  options "--force-yes"
end

package "xcp-xe" do
  action :install
end


bash "Correct xend startup script" do
  user "root"
  code <<-EOH
  sed -i -e 's/xend_start$/#xend_start/' -e 's/xend_stop$/#xend_stop/' /etc/init.d/xend
  update-rc.d xendomains disable
  EOH
  not_if { File.exists?("/var/lib/xcp/setup") }
end

execute "mv /etc/grub.d/10_linux /etc/grub.d/25_linux && update-grub2" do
  user "root"
  not_if { File.exists?("/var/lib/xcp/setup") }
end

execute "echo 'TOOLSTACK=\"xapi\"' > /etc/default/xen" do
  user "root"
  action :run
  not_if { File.exists?("/var/lib/xcp/setup") }
end

def_iface = node[:network][:default_interface]
def_gw    = node[:network][:default_gateway]
def_ip    = node[:ipaddress]
iface = { :name => node[:xenserver][:mgm_bridge_name],
          :ip => def_ip,
          :netmask =>  node[:network][:interfaces][def_iface][:addresses][def_ip][:netmask],
          :broadcast =>  node[:network][:interfaces][def_iface][:addresses][def_ip][:broadcast],
          :gateway => node[:network][:default_gateway],
          :bridge_ports => node[:xenserver][:mgm_bridge_pif]
}

template "/etc/network/interfaces" do
  source "interfaces.erb"
  owner "root"
  group "root"
  mode 0644
  variables( :iface => iface)
  not_if { File.exists?("/var/lib/xcp/setup") }
end

execute "touch /var/lib/xcp/setup"


#execute "Reboot to switch to xen kernel" do
#  command "touch /var/lib/xcp/reboot-stage1 && reboot -f now && sleep 10"
#  user "root"
#  not_if { File.exists?("/var/lib/xcp/reboot-stage1") }
#end



