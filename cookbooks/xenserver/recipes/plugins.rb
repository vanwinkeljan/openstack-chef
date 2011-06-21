#
# Cookbook Name:: xenserver
# Recipe:: plugins
#
# Copyright 2011, Rackspace
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

# FIXME this should use an RPM package to install the plugins in dom0
bash "install plugins" do
  user "root"
  code <<-EOH
curl #{node[:xenserver][:plugins_url]} | tar xvz -C /etc/xapi.d/plugins"
chmod a+x /etc/xapi.d/plugins/*
sed -i -e "s/enabled=0/enabled=1/" /etc/yum.repos.d/CentOS-Base.repo
  EOH
  not_if { File.exists?("/etc/xapi.d/plugins/migration") }
end

package "parted"
