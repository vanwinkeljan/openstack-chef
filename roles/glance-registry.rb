name "glance-registry"

run_list(
    "recipe[apt::noauth]",
    "recipe[vpc::apt_config]",
    "recipe[glance::registry]"
)
