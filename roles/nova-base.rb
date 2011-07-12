name "nova-base"

run_list(
	"recipe[apt::noauth]",
	"recipe[vpc::my_ip]",
	"recipe[vpc::apt_config]",
    "recipe[nova::common]"
)

default_attributes(
	"nova" => {
		"libvirt_type" => "qemu",
		"creds" => {
		"user" => "stacker",
		"group" => "stacker",
		"dir" => "/home/stacker"
		},
		"network_manager" => "nova.network.manager.FlatDHCPManager",
		"default_project" => "admin",
		"glance_api_servers" => "glance1:9292",
		"flat_network_bridge" => "xenbr0",
		"flat_network_dhcp_start" => "192.168.0.2",
		"fixed_range" => "192.168.0.0/24",
		"floating_range" => "172.20.0.0/24",
		"network" => "192.168.0.0/24 1 254",
		"image_service" => "nova.image.glance.GlanceImageService",
		"images" => ["http://images.ansolabs.com/tty.tgz"]
	}
)
