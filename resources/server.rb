property :server_address, String, name_attribute: true
property :farm, String, default: 'myServerFarm'
property :weight, Integer, default: 100
property :port, Integer, default: 80
property :ssl_port, Integer, default: 443

appcmd = "#{node['iis']['home']}\\appcmd.exe"

default_action :add
action :add do
  iis_lb_farm new_resource.farm

  iis_config "add server #{new_resource.server_address} to #{new_resource.farm} server farm" do
    cfg_cmd "-section:webFarms /+\"[name='#{new_resource.farm}'].[address='#{new_resource.server_address}']\" /commit:apphost"
    not_if { shell_out("#{appcmd} search config /section:webFarms /\"[name='#{new_resource.farm}'].[address='#{new_resource.server_address}']\".address").stdout.chomp == 'CONFIGSEARCH "MACHINE/WEBROOT/APPHOST"' }
  end

  ["weight:#{new_resource.weight}",
   "httpPort:#{new_resource.port}",
   "httpsPort:#{new_resource.ssl_port}"].each do |server_parameter|
    iis_config "set #{server_parameter} on #{new_resource.server_address} in #{new_resource.farm}" do
      cfg_cmd "-section:webFarms /\"[name='#{new_resource.farm}'].[address='#{new_resource.server_address}']\".applicationRequestRouting.#{server_parameter} /commit:apphost"
      not_if { shell_out("#{appcmd} search config /section:webFarms /\"[name='#{new_resource.farm}'].[address='#{new_resource.server_address}']\".applicationRequestRouting.#{server_parameter}").stdout.chomp == 'CONFIGSEARCH "MACHINE/WEBROOT/APPHOST"' }
    end
  end
end

action :remove do
  iis_config "remove server #{new_resource.server_address} from #{new_resource.farm} server farm" do
    cfg_cmd "-section:webFarms /-\"[name='#{new_resource.farm}'].[address='#{new_resource.server_address}']\" /commit:apphost"
    only_if { shell_out("#{appcmd} search config /section:webFarms /\"[name='#{new_resource.farm}'].[address='#{new_resource.server_address}']\".address").stdout.chomp == 'CONFIGSEARCH "MACHINE/WEBROOT/APPHOST"' }
  end
end
