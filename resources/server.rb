property :server_address, :name_attribute => true, :kind_of => String
property :farm_name, :default => 'myServerFarm', :kind_of => String
property :weight, :default => 100, :kind_of => Fixnum
property :port, :default => 80, :kind_of => Fixnum
property :ssl_port, :default => 443, :kind_of => Fixnum

default_action :add
action :add do
  appcmd = "#{node['iis']['home']}\\appcmd.exe"

    iis_lb_farm new_resource.farm_name

    iis_config "add server #{new_resource.server_address} to #{new_resource.farm_name} web farm" do
      cfg_cmd "-section:webFarms /+\"[name='#{new_resource.farm_name}'].[address='#{new_resource.server_address}']\" /commit:apphost"
      not_if {(shell_out("#{appcmd} search config /section:webFarms /\"[name='#{new_resource.farm_name}'].[address='#{new_resource.server_address}']\".address").stdout).chomp == "CONFIGSEARCH \"MACHINE/WEBROOT/APPHOST\""}
    end

    ["weight:#{new_resource.weight}",
     "httpPort:#{new_resource.port}",
     "httpsPort:#{new_resource.ssl_port}"
    ].each do |server_parameter|
      iis_config "-section:webFarms /\"[name='#{new_resource.farm_name}'].[address='#{new_resource.server_address}']\".applicationRequestRouting.#{server_parameter} /commit:apphost" do
        not_if {(shell_out("#{appcmd} search config /section:webFarms /\"[name='#{new_resource.farm_name}'].[address='#{new_resource.server_address}']\".applicationRequestRouting.#{server_parameter}").stdout).chomp == "CONFIGSEARCH \"MACHINE/WEBROOT/APPHOST\""}
      end
    end
end
