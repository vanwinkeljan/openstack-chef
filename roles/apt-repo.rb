name "apt-repo"

run_list(
    "recipe[apt::repo]"
)

default_attributes(
	"apt" => {
		"repo_name" => "openstack",
		"repo_codename" => "maverick",
		"repo_archs" => "amd64",
		"upload_package_dir" => "/root/openstack-packages"
	}
)
