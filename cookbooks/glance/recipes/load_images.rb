#
# Cookbook Name:: glance
# Recipe:: load_images

include_recipe "#{@cookbook_name}::common"

package "curl"

image_list = node[:glance][:image_list]
if image_list then
  image_list.each do |img|
    bash "glance add: #{img[:name]}" do
      cwd "/tmp"
      user "root"
      code <<-EOH
        [ -f /root/openstackrc ] && source /root/openstackrc
        curl #{img[:url]} | glance add name=#{img[:name]} disk_format=#{img[:disk_format]} container_format=#{img[:container_format]} is_public=True
        touch /var/lib/glance/chef_images_loaded
      EOH
      not_if do File.exists?("/var/lib/glance/chef_images_loaded") end
    end
  end
end

tty_linux_image = node[:glance][:tty_linux_image]
if tty_linux_image and not tty_linux_image.empty? then
  bash "glance add: tty linux" do
    cwd "/tmp"
    user "root"
    code <<-EOH
      mkdir -p /var/lib/glance/
      [ -f /root/openstackrc ] && source /root/openstackrc
      curl #{tty_linux_image} | tar xvz -C /tmp/
      ARI_ID=`glance add name="ari-tty" type="ramdisk" disk_format="ari" container_format="ari" is_public=true < /tmp/tty_linux/ramdisk | sed 's/.*\: //g'`
      AKI_ID=`glance add name="aki-tty" type="kernel" disk_format="aki" container_format="aki" is_public=true < /tmp/tty_linux/kernel | sed 's/.*\: //g'`
      glance add name="ami-tty" type="kernel" disk_format="ami" container_format="ami" ramdisk_id="$ARI_ID" kernel_id="$AKI_ID" is_public=true < /tmp/tty_linux/image
      touch /var/lib/glance/chef_images_loaded
    EOH
    not_if do File.exists?("/var/lib/glance/chef_images_loaded") end
  end
end
