property :farm_name, String, name_attribute: true
property :algorithm, String, equal_to: %w(WeightedRoundRobin LeastRequests LeastResponseTime WeightedTotalTraffic RequestHash), default: 'WeightedRoundRobin'

appcmd = "#{node['iis']['home']}\\appcmd.exe"

default_action :create
action :create do
  include_recipe 'iis-lb::_arr'

  iis_config "create #{new_resource.farm_name} web farm" do
    cfg_cmd "-section:webFarms /+\"[name='#{new_resource.farm_name}']\" /commit:apphost"
    not_if { shell_out("#{appcmd} search config /section:webFarms /\"[name='#{new_resource.farm_name}']\".name").stdout.chomp == 'CONFIGSEARCH "MACHINE/WEBROOT/APPHOST"' }
  end

  iis_config "set loadbalancing algorithm for #{new_resource.farm_name} to #{new_resource.algorithm}" do
    cfg_cmd "/section:webFarms /\"[name='#{new_resource.farm_name}']\".applicationRequestRouting.loadBalancing.algorithm:#{new_resource.algorithm} /commit:apphost"
    not_if { shell_out("#{appcmd} search config /section:webFarms /\"[name='#{new_resource.farm_name}']\".applicationRequestRouting.loadBalancing.algorithm:#{new_resource.algorithm}").stdout.chomp == 'CONFIGSEARCH "MACHINE/WEBROOT/APPHOST"' }
  end

  iis_config "create url rewrite rule for #{new_resource.farm_name} web farm" do
    cfg_cmd "-section:system.webServer/rewrite/globalRules /+\"[name='ARR_#{new_resource.farm_name}_loadbalance', patternSyntax='Wildcard',stopProcessing='True']\" /commit:apphost"
    not_if { shell_out("#{appcmd} search config /section:system.webServer/rewrite/globalRules /\"[name='ARR_#{new_resource.farm_name}_loadbalance']\".name").stdout.chomp == 'CONFIGSEARCH "MACHINE/WEBROOT/APPHOST"' }
  end

  iis_config 'set the url match for the rewrite rule' do
    cfg_cmd "-section:system.webServer/rewrite/globalRules /[name='ARR_#{new_resource.farm_name}_loadbalance',patternSyntax='Wildcard',stopProcessing='True'].match.url:\"*\"  /commit:apphost"
    not_if { shell_out("#{appcmd} search config /section:system.webServer/rewrite/globalRules /\"[name='ARR_#{new_resource.farm_name}_loadbalance']\".match.url:\"*\"").stdout.chomp == 'CONFIGSEARCH "MACHINE/WEBROOT/APPHOST"' }
  end

  iis_config "route all requests to the #{new_resource.farm_name} web farm" do
    cfg_cmd "-section:system.webServer/rewrite/globalRules /[name='ARR_#{new_resource.farm_name}_loadbalance',patternSyntax='Wildcard',stopProcessing='True'].action.type:\"Rewrite\" /[name='ARR_#{new_resource.farm_name}_loadbalance',patternSyntax='Wildcard',stopProcessing='True'].action.url:\"http://#{new_resource.farm_name}/{R:0}\"  /commit:apphost"
    not_if { shell_out("#{appcmd} search config /section:system.webServer/rewrite/globalRules /\"[name='ARR_#{new_resource.farm_name}_loadbalance'].action.url:\"http://#{new_resource.farm_name}/{R:0}\"").stdout.chomp == 'CONFIGSEARCH "MACHINE/WEBROOT/APPHOST"' }
  end
end

action :remove do
  iis_config "remove #{new_resource.farm_name} web farm" do
    cfg_cmd "-section:webFarms /-\"[name='#{new_resource.farm_name}']\" /commit:apphost"
    only_if { shell_out("#{appcmd} search config /section:webFarms /\"[name='#{new_resource.farm_name}']\".name").stdout.chomp == 'CONFIGSEARCH "MACHINE/WEBROOT/APPHOST"' }
  end
end
