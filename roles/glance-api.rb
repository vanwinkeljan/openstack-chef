name "glance-api"

run_list(
    "recipe[apt::noauth]",
    "recipe[vpc::apt_config]",
    "recipe[glance::api]"
)
