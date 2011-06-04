name "nova-mysql-server"
description "MySQL server for Nova"

run_list(
  "recipe[mysql::server]",
  "recipe[nova::mysql]"
)
