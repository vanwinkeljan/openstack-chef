# This recipe contains setup steps required for Nova Compute to work
# correctly on our Stock Ubuntu Cloud Servers images

directory "/dev/cgroup" do
  owner "root"
  group "root"
  mode "0755"
  action :create
end

execute "mount -t cgroup none /dev/cgroup -o devices" do
  not_if "mount | grep cgroup"
end

execute "apt-get -y --force-yes install libvirt0=#{node[:libvirt][:version]} libvirt-bin=#{node[:libvirt][:version]} python-libvirt=#{node[:libvirt][:version]}" do
  not_if "dpkg -l libvirt-bin | grep #{node[:libvirt][:version]}"
end

service "libvirt-bin"

cookbook_file "/etc/libvirt/qemu.conf" do
  source "qemu.conf"
  mode "0644"
  notifies :restart, resources(:service => "libvirt-bin")
end
