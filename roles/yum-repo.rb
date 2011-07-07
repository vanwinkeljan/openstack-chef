name "yum-repo"

run_list(
    "recipe[yum::repo]"
)

default_attributes(
	"apt" => {
		"repo_base_directory" => "/var/packages/rpms",
		"upload_packages_dir" => "/root/openstack-rpms"
	}
)
