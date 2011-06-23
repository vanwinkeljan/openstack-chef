name "nova-compute"

run_list(
    "role[nova-base]",
	"recipe[nova::compute]"
)
