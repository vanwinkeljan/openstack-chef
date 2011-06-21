# create and configure an instance on the XenServer via XenStore
# Requires that the XVA image have the Openstack Guest Agent installed
define :create_instance do

hostname=params[:name]

image_path=params[:image_path]
if image_path.blank? then
  image_path=node[:xenserver][:image_path]
end
xva_image_url=params[:xva_image_url]
if xva_image_url.blank? then
  xva_image_url=node[:xenserver][:xva_image_url]
end

file_data_array=params[:file_data_array] # array of {'filename' => '<filename>', 'data' => <data>}

# NOTE: this requires that the image_path directory already exists
bash "download domU image" do
  user "root"
  code <<-EOH
  curl -s #{xva_image_url} -o #{image_path}
  EOH
  not_if do File.exists?(image_path) end
end

bash "create-instance-#{hostname}" do
  user "root"
  code <<-EOH
    UUID=$(xe vm-import filename=#{image_path})
    xe vm-param-set name-label=#{hostname} uuid=$UUID
    xe vm-start uuid=$UUID
  EOH
  not_if "xe vm-list name-label=#{hostname} | grep '.*name-label.*: #{hostname}'"
end

if file_data_array then
  fd_count=0
  file_data_array.each do |hash|
    file_data = Base64.encode64("#{hash['filename']},#{hash['data']}")

    bash "inject-file-#{fd_count}:#{hostname}}" do
      action :nothing
      user "root"
      code <<-EOH
        UUID=$(xe vm-list name-label=#{hostname} | grep uuid | sed -e 's|.*: ||')
        DOMID=$(xe vm-param-get uuid=$UUID param-name="dom-id")
        xenstore-write -s /local/domain/$DOMID/data/host/#{fd_count} '{"name": "injectfile", "value": "#{file_data}"}'
        xenstore-rm -s /local/domain/$DOMID/data/guest/#{fd_count}
        until [ -n "$INJECT_RETVAL" ]; do
          INJECT_RETVAL=$(xenstore-read -s /local/domain/$DOMID/data/guest/#{fd_count} 2> /dev/null)
        done
        xenstore-rm -s /local/domain/$DOMID/data/host/#{fd_count}
      EOH
      subscribes :run, resources("bash[create-instance-#{hostname}]"), :immediately
    end
  end
end

# networking
network_info = {
  "label" => "public",
  "broadcast" => params[:broadcast],
  "ips" => [{
    "ip" => params[:ip_address],
    "netmask" => params[:netmask],
    "enabled" => "1"}],
  "mac" => params[:mac],
  "dns" => [params[:dns_nameservers]],
  "gateway" => params[:gateway]
}

bash "configure network #{hostname}" do
  action :nothing
  user "root"
  code <<-EOH
    UUID=$(xe vm-list name-label=#{hostname} | grep uuid | sed -e 's|.*: ||')
    DOMID=$(xe vm-param-get uuid=$UUID param-name="dom-id")
    xenstore-write -s /local/domain/$DOMID/vm-data/hostname '#{hostname}'
    xenstore-write -s /local/domain/$DOMID/vm-data/networking/123_nw_info '#{network_info.to_json}'

    xenstore-write -s /local/domain/$DOMID/data/host/123_reset_nw '{"name": "resetnetwork", "value": ""}'
    xenstore-rm -s /local/domain/$DOMID/data/guest/123_reset_nw
    until [ -n "$NW_RETVAL" ]; do
      NW_RETVAL=$(xenstore-read -s /local/domain/$DOMID/data/guest/123_reset_nw 2> /dev/null)
    done
    xenstore-rm -s /local/domain/$DOMID/data/host/123_reset_nw
  EOH
  subscribes :run, resources("bash[create-instance-#{hostname}]"), :immediately
end

end
