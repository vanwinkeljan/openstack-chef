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
  apt_key_env ({"http_proxy" => "http://bluecoat-be01.alcatel.fr:1080"})
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

execute "touch /var/lib/xcp/setup"




