#
# Cookbook Name:: iis-lb
# Recipe:: lb
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

appcmd = "#{node['iis']['home']}\\appcmd.exe"

include_recipe 'webpi'

webpi_product 'ARRv3_0' do
  accept_eula true
  action :install
end

%w( myServerFarm ).each do |farm|
  iis_config "create #{farm} web farm" do
    cfg_cmd "-section:webFarms /+\"[name='#{farm}']\" /commit:apphost"
    not_if {(shell_out("#{appcmd} search config /section:webFarms /\"[name='#{farm}']\".name").stdout).chomp == 'CONFIGSEARCH "MACHINE/WEBROOT/APPHOST"'}
  end

  node['iis-lb']['members'].each do |server|
    iis_config "add server #{server['address']} to #{farm} web farm" do
      cfg_cmd "-section:webFarms /+\"[name='#{farm}'].[address='#{server['address']}']\" /commit:apphost"
      not_if {(shell_out("#{appcmd} search config /section:webFarms /\"[name='#{farm}'].[address='#{server['address']}']\".address").stdout).chomp == "CONFIGSEARCH \"MACHINE/WEBROOT/APPHOST\""}
    end


    ["weight:#{server['weight']}",
     "httpPort:#{server['port']}",
     "httpsPort:#{server['ssl_port']}"
    ].each do |server_parameter|
      iis_config "-section:webFarms /\"[name='#{farm}'].[address='#{server['address']}']\".applicationRequestRouting.#{server_parameter} /commit:apphost" do
        not_if {(shell_out("#{appcmd} search config /section:webFarms /\"[name='#{farm}'].[address='#{server['address']}']\".applicationRequestRouting.#{server_parameter}").stdout).chomp == "CONFIGSEARCH \"MACHINE/WEBROOT/APPHOST\""}
      end
    end
  end

  iis_config "set loadbalancing algorithm for #{farm} to WeightedRoundRobin" do
    cfg_cmd "/section:webFarms /\"[name='#{farm}']\".applicationRequestRouting.loadBalancing.algorithm:WeightedRoundRobin /commit:apphost"
    not_if {(shell_out("#{appcmd} search config /section:webFarms /\"[name='#{farm}']\".applicationRequestRouting.loadBalancing.algorithm:WeightedRoundRobin").stdout).chomp == "CONFIGSEARCH \"MACHINE/WEBROOT/APPHOST\""}
  end

  iis_config "create url rewrite rule for #{farm} web farm" do
    cfg_cmd "-section:system.webServer/rewrite/globalRules /+\"[name='ARR_#{farm}_loadbalance', patternSyntax='Wildcard',stopProcessing='True']\" /commit:apphost"
    not_if {(shell_out("#{appcmd} search config /section:system.webServer/rewrite/globalRules /\"[name='ARR_#{farm}_loadbalance']\".name").stdout).chomp == "CONFIGSEARCH \"MACHINE/WEBROOT/APPHOST\""}
  end

  iis_config 'set the url match for the rewrite rule' do
    cfg_cmd "-section:system.webServer/rewrite/globalRules /[name='ARR_#{farm}_loadbalance',patternSyntax='Wildcard',stopProcessing='True'].match.url:\"*\"  /commit:apphost"
    not_if {(shell_out("#{appcmd} search config /section:system.webServer/rewrite/globalRules /\"[name='ARR_#{farm}_loadbalance']\".match.url:\"*\"").stdout).chomp == "CONFIGSEARCH \"MACHINE/WEBROOT/APPHOST\""}
  end

  iis_config "route all requests to the #{farm} web farm" do
    cfg_cmd "-section:system.webServer/rewrite/globalRules /[name='ARR_#{farm}_loadbalance',patternSyntax='Wildcard',stopProcessing='True'].action.type:\"Rewrite\" /[name='ARR_#{farm}_loadbalance',patternSyntax='Wildcard',stopProcessing='True'].action.url:\"http://#{farm}/{R:0}\"  /commit:apphost"
    not_if {(shell_out("#{appcmd} search config /section:system.webServer/rewrite/globalRules /\"[name='ARR_#{farm}_loadbalance'].action.url:\"http://#{farm}/{R:0}\"").stdout).chomp == "CONFIGSEARCH \"MACHINE/WEBROOT/APPHOST\""}
  end
end
