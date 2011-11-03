name "glance-postgresql-server"
description "PostgreSQL server for Nova"

run_list(
  "recipe[postgresql::server]",
  "recipe[glance::postgresql]"
)

default_attributes(
  "glance" => {
    "postgresql" => true
  },
  "postgresql" => {
    "hba_records" => [
      "host    all         all         0.0.0.0/0             md5"
    ]
  }
)
