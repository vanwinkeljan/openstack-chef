default[:xenserver][:xva_image_url] = "http://c3324746.r46.cf0.rackcdn.com/maverick_agent.xva"
default[:xenserver][:image_path] = "/root/maverick_agent.xva"
default[:xenserver][:license_filename] = "/root/.xenserver_license.txt"
default[:xenserver][:sr_name_label] = "Local storage"

#XenServer plugins (FIXME: use an RPM to deploy plugins to dom0)
default[:xenserver][:plugins][:url] = "http://172.19.0.1/plugins.tar.gz"
