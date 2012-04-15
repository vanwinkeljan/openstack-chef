#
# Cookbook Name:: nova
# Attributes:: default
#
# Copyright 2008-2009, Opscode, Inc.
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

::Chef::Node.send(:include, Opscode::OpenSSL::Password)

include_attribute "keystone"
include_attribute "glance"

default[:nova][:mysql] = true
default[:nova][:postgresql] = false

# Config File Stuff
default[:nova][:verbose] = "True"
default[:nova][:debug] = "True"
default[:nova][:state_path] = "/var/lib/nova"
default[:nova][:lock_path] = "/var/lock/nova"
default[:nova][:auth_strategy] = "keystone"
default[:nova][:log_config] = "/etc/nova/logging.cnf"
default[:nova][:log_file] = "/var/log/nova/nova.log"
default[:nova][:allow_resize_to_same_host] = "True"
default[:nova][:compute_scheduler_driver] = "nova.scheduler.filter_scheduler.FilterScheduler"
default[:nova][:dhcpbridge_flagfile] = "/etc/nova/nova.conf"
default[:nova][:fixed_range] = "10.0.0.0/24"
default[:nova][:network_manager] = "nova.network.manager.FlatDHCPManager"
default[:nova][:volume_group] = "nova-volumes"
default[:nova][:volume_name_template] = "volume-%08x"
default[:nova][:rootwrap] = "/usr/bin/nova-rootwrap"
default[:nova][:root_helper] = "sudo #{node[:nova][:rootwrap]}"
default[:nova][:osapi_compute_extension] = "nova.api.openstack.compute.contrib.standard_extensions"
default[:nova][:my_ip] = ipaddress
default[:nova][:public_interface] = "eth0"
default[:nova][:vlan_interface] = "eth0"
default[:nova][:libvirt_type] = "kvm"
default[:nova][:instance_name_template] = "instance-%08x"
default[:nova][:api_paste_config] = "/etc/nova/api-paste.ini"
default[:nova][:image_service] = "nova.image.glance.GlanceImageService"
default[:nova][:multi_host] = "True"

default[:nova][:ec2_dmz_host] = ipaddress

default[:nova][:ec2_listen_port] = node[:keystone][:nova][:ec2_listen_port]
default[:nova][:osapi_compute_listen_port] = node[:keystone][:nova][:osapi_compute_listen_port]
default[:nova][:metadata_listen_port] = "8775"
default[:nova][:osapi_volume_listen_port] = node[:keystone][:nova][:osapi_volume_listen_port]

default[:nova][:force_dhcp_release] = "True"
default[:nova][:connection_type] = "libvirt"
default[:nova][:glance_api_servers] = "#{node[:glance][:my_ip]}:#{node[:glance][:api_bind_port]}"


if node[:nova] and node[:nova][:connection_type]  and node[:nova][:connection_type] == "xenapi"
  default[:nova][:firewall_driver] = 'nova.virt.xenapi.firewall.Dom0IptablesFirewallDriver'
else
  default[:nova][:firewall_driver]='nova.virt.libvirt.firewall.IptablesFirewallDriver'
end

#IP Ranges (allocated via nova-manage)

default[:nova][:floating_range] = "10.128.0.0/24"


# File Backe LVM Options

default[:nova][:vg_file_size] = "10G"

#keystone settings
default[:nova][:keystone_service_protocol] = "http"
default[:nova][:keystone_service_host] = node[:keystone][:my_ip]
default[:nova][:keystone_service_port] = node[:keystone][:public_port]
default[:nova][:keystone_auth_host] = node[:keystone][:my_ip]
default[:nova][:keystone_auth_port] = node[:keystone][:admin_port]
default[:nova][:keystone_auth_protocol] = "http"
default[:nova][:keystone_auth_uri] = node[:keystone][:endpoints]["keystone"][:publicurl]
default[:nova][:keystone_admin_tenant_name] = "service"
default[:nova][:keystone_admin_user] = "nova"
default[:nova][:keystone_admin_password] = node[:keystone][:users]["nova"][:pass]


