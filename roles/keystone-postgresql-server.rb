name "keystone-postgresql-server"
description "PostgreSQL server for Keystone"

run_list(
  "recipe[postgresql::server]",
  "recipe[keystone::postgresql]"
)

default_attributes(
  "keystone" => {
    "postgresql" => true
  },
  "postgresql" => {
    "hba_records" => [
      "host    all         all         0.0.0.0/0             md5"
    ]
  }
)
