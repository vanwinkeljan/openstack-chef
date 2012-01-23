name "nova-cert"

run_list(
    "role[nova-base]",
    "recipe[nova::cert]"
)
