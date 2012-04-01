default[:keystone][:config_file] = "/etc/keystone/keystone.conf"
default[:keystone][:log_config] = "/etc/keystone/logging.cnf"
default[:keystone][:log_file] = "/var/log/keystone/keystone.log"
default[:keystone][:db_file] = "/var/lib/keystone/keystone.db"

default[:keystone][:verbose] = "True"
default[:keystone][:debug] = "False"

default[:keystone][:use_syslog] = "False"

default[:keystone][:mysql] = false
default[:keystone][:postgresql] = false
default[:keystone][:sql_connection] = "sqlite:////var/lib/keystone/keystone.db"
default[:keystone][:sql_idle_timeout] = "60"
#default[:keystone][:service_protocol] = "http"
default[:keystone][:bind_host] = "0.0.0.0"
default[:keystone][:public_port] = "5000"
#default[:keystone][:admin_protocol] = "http"
#default[:keystone][:admin_host] = "0.0.0.0"
default[:keystone][:admin_port] = "35357"
default[:keystone][:admin_token] = "ADMIN"
default[:keystone][:service_admin_role] = "KeystoneServiceAdmin"
default[:keystone][:compute_port] = "8774"

default[:keystone][:service_endpoint] = "http://localhost:35357/v2.0"

#default[:keystone][:hash_password] = "True"
#default[:keystone][:service_ssl] = "False"
#default[:keystone][:admin_ssl] = "False"
#default[:keystone][:certfile] = "/etc/keystone/ssl/certs/keystone.pem"
#default[:keystone][:keyfile] = "/etc/keystone/ssl/private/keystonekey.pem"
#default[:keystone][:ca_certs] = "/etc/keystone/ssl/certs/ca.pem"
#default[:keystone][:cert_required] = "True"

#default[:keystone][:sql_connection] = "sqlite:////var/lib/keystone/keystone.sqlite"

#default setup commands for keystone::setup recipe
default[:keystone][:setup_commands] = [
"tenant-create --name 'default' --description \"Default Tenant\" --enabled \"true\" | grep id | cut -d \"|\" -f 3 > /tmp/tenant_default_id",
"user-create --name admin --pass AABBCC112233 --tenant_id `cat /tmp/tenant_default_id` --enabled \"true\" | grep id | cut -d \"|\" -f 3 > /tmp/user_admin_id",
"role-create --name admin  | grep id | cut -d \"|\" -f 3 > /tmp/role_admin_id",
"user-role-add --user `cat /tmp/user_admin_id` --tenant_id `cat /tmp/tenant_default_id` --role `cat /tmp/role_admin_id`",
"tenant-create --name service --description \"Service Tenant\" --enabled \"true\" | grep id | cut -d \"|\" -f 3 > /tmp/tenant_service_id",
"service-create --name=nova --type=compute --description=\"Nova Compute Service\" | grep id | cut -d \"|\" -f 3 > /tmp/service_nova_id",
"service-create --name=ec2 --type=ec2 --description=\"EC2 Compatibility Layer\" | grep id | cut -d \"|\" -f 3 > /tmp/service_ec2_id",
"service-create --name=glance --type=image --description=\"Glance Image Service\" | grep id | cut -d \"|\" -f 3 > /tmp/service_glance_id",
"service-create --name=keystone --type=identity --description=\"Keystone Identity Service\" | grep \"id \" | cut -d \"|\" -f 3 > /tmp/service_id_id",
"service-create --name=swift --type=object-store --description=\"Swift Service\" | grep id | cut -d \"|\" -f 3 > /tmp/service_swift_id",
"endpoint-create \
 --region RegionOne \
 --service_id `cat /tmp/service_id_id` \
 --publicurl http://#{node[:keystone][:my_ip]}:#{node[:keystone][:public_port]}/v2 \
 --adminurl http://#{node[:keystone][:my_ip]}:#{node[:keystone][:admin_port]}/v2 \
 --internalurl http://#{node[:keystone][:my_ip]}:#{node[:keystone][:public_port]}/v2"
]

default[:keystone][:creds] = [
  {
  :os_user => "root",
  :auth_user => "admin",
  :auth_key => "AABBCC112233",
  :auth_tenant => "default",
  :auth_url => "http://login:5000/v2.0/"
  }
]

