default[:glance][:api_config_file]="/etc/glance/glance-api.conf"
default[:glance][:registry_config_file]="/etc/glance/glance-registry.conf"
default[:glance][:log_dir]="/var/log/glance"
default[:glance][:working_directory]="/var/lib/glance"
default[:glance][:pid_directory]="/var/run/glance/"

default[:glance][:verbose] = "True"
default[:glance][:debug] = "True"
default[:glance][:api_bind_host] = "0.0.0.0"
default[:glance][:api_bind_port] = "9292"
default[:glance][:registry_host] = "0.0.0.0"
default[:glance][:registry_bind_host] = "0.0.0.0"
default[:glance][:registry_bind_port] = "9191"
default[:glance][:sql_connection] = "sqlite:////var/lib/glance/glance.sqlite"
default[:glance][:sql_idle_timeout] = "3600"

#default_store choices are: file, http, https, swift, s3
default[:glance][:default_store] = "file"
default[:glance][:filesystem_store_datadir] = "/var/lib/glance/images"

default[:glance][:swift_store_auth_address] = "127.0.0.1:8080/v1.0/"
default[:glance][:swift_store_user] = "jdoe"
default[:glance][:swift_store_key] = "a86850deb2742ec3cb41518e26aa2d89"
default[:glance][:swift_store_container] = "glance"
default[:glance][:swift_store_create_container_on_put] = "False"

default[:glance][:image_cache_enabled] = "False"
default[:glance][:image_cache_datadir] = "/var/lib/glance/image-cache/"

#auth type (noauth or keystone)
default[:glance][:auth_type] = "noauth"

#keystone settings
default[:glance][:keystone_service_protocol] = "http"
default[:glance][:keystone_service_host] = "127.0.0.1"
default[:glance][:keystone_service_port] = "5000"
default[:glance][:keystone_auth_host] = "127.0.0.1"
default[:glance][:keystone_auth_port] = "5001"
default[:glance][:keystone_auth_protocol] = "http"
default[:glance][:keystone_auth_uri] = "http://127.0.0.1:5000/"
default[:glance][:keystone_admin_token] = "999888777666"


# Example Attributes for the glance::load_images recipe:
#
# default[:glance][:tty_linux_image] = "http://abc.rackcdn.com/tty_linux.tar.gz"
#
# default[:glance][:image_list] = [{:name => "squeeze", :url => "http://abc.rackcdn.com/squeeze-agent-0.0.1.28.ova", :disk_format => "vhd", :container_format="ovf"}]
