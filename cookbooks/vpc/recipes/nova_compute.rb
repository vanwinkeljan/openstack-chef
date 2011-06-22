# NOTE: I manually reimplented the nova-compute startup here so that it
# works on stock cloud servers. This works around the fact that stock
# Ubuntu Cloud Servers images don't have the 'nbd' (network block device)
# kernel module.

include_recipe "nova::common"

package "nova-compute" do
  options "--force-yes"
  action :install
end

template "/etc/init/nova-compute.conf" do
  source "nova-compute.conf"
  mode "0644"
end

if node[:nova][:connection_type] and node[:nova][:connection_type] == "xenapi" then
	# FIXME: create a python XenAPI package
	package "python-pip"
	execute "/usr/bin/pip install xenapi" do
		not_if "python -c 'import XenAPI'"
	end
end

service "nova-compute" do
  restart_command "stop nova-compute; start nova-compute"
  stop_command "stop nova-compute"
  start_command "start nova-compute"
  status_command "status nova-compute | cut -d' ' -f2 | cut -d'/' -f1 | grep start"
  supports :status => true, :restart => true
  action :start
  subscribes :restart, resources(:template => ["/etc/nova/nova.conf", "/etc/init/nova-compute.conf"])
end
