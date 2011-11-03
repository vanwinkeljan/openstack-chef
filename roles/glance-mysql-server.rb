name "glance-mysql-server"
description "MySQL server for Glance"

run_list(
  "recipe[mysql::server]",
  "recipe[glance::mysql]"
)

default_attributes(
  "glance" => {
    "mysql" => true
  }
)
