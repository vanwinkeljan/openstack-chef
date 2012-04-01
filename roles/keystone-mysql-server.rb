name "keystone-mysql-server"
description "MySQL server for Keystone"

run_list(
  "recipe[mysql::server]",
  "recipe[keystone::mysql]"
)

default_attributes(
  "keystone" => {
    "mysql" => true
  }
)
