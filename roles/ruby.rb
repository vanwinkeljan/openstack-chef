name "ruby"
description "Setup Ruby and w/ build environment to build Rubygems"

run_list(
  "recipe[build-essential]",
  "recipe[ruby]"
)
