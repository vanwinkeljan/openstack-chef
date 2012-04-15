
::Chef::Node.send(:include, Opscode::OpenSSL::Password)

default[:keystone][:config_file] = "/etc/keystone/keystone.conf"
default[:keystone][:log_config] = "/etc/keystone/logging.cnf"
default[:keystone][:log_file] = "/var/log/keystone/keystone.log"
default[:keystone][:db_file] = "/var/lib/keystone/keystone.db"

default[:keystone][:verbose] = "True"
default[:keystone][:debug] = "True"

default[:keystone][:use_syslog] = "False"

default[:keystone][:my_ip] = ipaddress
default[:keystone][:mysql] = false
default[:keystone][:postgresql] = false
default[:keystone][:sql_connection] = "sqlite:////var/lib/keystone/keystone.db"
default[:keystone][:sql_idle_timeout] = "60"
default[:keystone][:bind_host] = "0.0.0.0"
default[:keystone][:public_port] = "5000"
default[:keystone][:admin_port] = "35357"
set_unless[:keystone][:admin_token] = secure_password
default[:keystone][:service_admin_role] = "KeystoneServiceAdmin"
default[:keystone][:compute_port] = "8774"

default[:keystone][:nova][:osapi_compute_listen_port] = "8774"
default[:keystone][:nova][:ec2_listen_port] = "8773"
default[:keystone][:glance][:api_bind_port] = "9292"
default[:keystone][:nova][:osapi_volume_listen_port] = "8776"

default[:keystone][:tenants] = [
  {
    :name => "default",
    :description => "Default Tenant"
  },
  {
    :name => "service",
    :description => "Service Tenant"
  }
]

default[:keystone][:horizon][:member] = "Member"

default[:keystone][:roles] = [
  "admin",
  node[:keystone][:horizon][:member]
]

default[:keystone][:tenants] = {
  "default" => {
    :description => "Default Tenant"
  },
  "service" => {
    :description => "Service Tenant"
  }
}

# Use set_unless so that we don't overide pass each run
set_unless[:keystone][:users] = {
  "admin" => {
    :pass => secure_password,
    :tenant => "default",
    :role => "admin"
  },
  "nova" => {
    :pass => secure_password,
    :tenant => "service",
    :role => "admin"
  },
  "glance" => {
    :pass => secure_password,
    :tenant => "service",
    :role => "admin"
  },
  "swift" => {
    :pass => secure_password,
    :tenant => "service",
    :role => "admin"
  },
  "keystone" => {
    :pass => secure_password,
    :tenant => "service",
    :role => "admin"
  }
}

default[:keystone][:services] = {
  "nova" => {
    :type => "compute",
    :description => "Nova Compute Service"
  },
  "ec2" => {
    :type => "ec2",
    :description => "EC2 Compatibility Layer"
  },
  "glance" => {
    :type => "image",
    :description => "Glance Image Service"
  },
  "keystone" => {
    :type => "identity",
    :description => "Keystone Identity Service"
  },
  "swift" => {
    :type => "object-store",
    :description => "Swift Service"
  },
  "volume" => {
    :type => "volume",
    :description => "Volume Service"
  }
}

default[:keystone][:nova][:osapi_compute_listen_port] = "8774"
default[:keystone][:nova][:ec2_listen_port] = "8773"
default[:keystone][:glance][:api_bind_port] = "9292"
default[:keystone][:nova][:osapi_volume_listen_port] = "8776"

default[:keystone][:endpoints] = {
  "nova" => {
    :region => "RegionOne",
    :service => "nova",
    :publicurl => "http://#{node[:fqdn]}:#{node[:keystone][:nova][:osapi_compute_listen_port]}/v2/$(tenant_id)s",
    :adminurl => "http://#{node[:fqdn]}:#{node[:keystone][:nova][:osapi_compute_listen_port]}/v2/$(tenant_id)s",
    :internalurl => "http://#{node[:fqdn]}:#{node[:keystone][:nova][:osapi_compute_listen_port]}/v2/$(tenant_id)s",
  },
  "ec2" => {
    :region => "RegionOne",
    :service => "ec2",
    :publicurl => "http://#{node[:fqdn]}:#{node[:keystone][:nova][:ec2_listen_port]}/services/Cloud",
    :adminurl => "http://#{node[:fqdn]}:#{node[:keystone][:nova][:ec2_listen_port]}/services/Admin",
    :internalurl => "http://#{node[:fqdn]}:#{node[:keystone][:nova][:ec2_listen_port]}/services/Cloud",
  },
  "glance" => {
    :region => "RegionOne",
    :service => "glance",
    :publicurl => "http://#{node[:fqdn]}:#{node[:keystone][:glance][:api_bind_port]}/v1",
    :adminurl => "http://#{node[:fqdn]}:#{node[:keystone][:glance][:api_bind_port]}/v1",
    :internalurl => "http://#{node[:fqdn]}:#{node[:keystone][:glance][:api_bind_port]}/v1",
  },
  "keystone" => {
    :region => "RegionOne",
    :service => "keystone",
    :publicurl => "http://#{node[:fqdn]}:#{node[:keystone][:public_port]}/v2.0",
    :adminurl => "http://#{node[:fqdn]}:#{node[:keystone][:admin_port]}/v2.0",
    :internalurl => "http://#{node[:fqdn]}:#{node[:keystone][:public_port]}/v2.0",
  },
  "volume" => {
    :region => "RegionOne",
    :service => "volume",
    :publicurl => "http://#{node[:fqdn]}:#{node[:keystone][:nova][:osapi_volume_listen_port]}/v1/$(tenant_id)s",
    :adminurl => "http://#{node[:fqdn]}:#{node[:keystone][:nova][:osapi_volume_listen_port]}/v1/$(tenant_id)s",
    :internalurl => "http://#{node[:fqdn]}:#{node[:keystone][:nova][:osapi_volume_listen_port]}/v1/$(tenant_id)s",
  }
}

default[:keystone][:creds] = [
  {
    :os_user => "root",
    :keystone_user => "admin"
  }
]

