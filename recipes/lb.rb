#
# Cookbook Name:: iis-lb
# Recipe:: lb
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

include_recipe 'webpi'

webpi_product 'ARRv3_0' do
  accept_eula true
  action :install
end

%w( myServerFarm ).each do |farm|
  iis_config "create #{farm} web farm" do
    cfg_cmd "-section:webFarms /+\"[name='#{farm}']\" /commit:apphost"
    not_if "#{ENV['WinDir']}\\System32\\inetsrv\\appcmd.exe set config /section:webFarms /\"[name='#{farm}']\".enabled:true"
  end

  node['iis-lb']['members'].each do |server|
    iis_config "add server #{server['address']} to #{farm} web farm" do
      cfg_cmd "-section:webFarms /+\"[name='#{farm}'].[address='#{server['address']}']\" /commit:apphost"
      not_if "#{ENV['WinDir']}\\System32\\inetsrv\\appcmd.exe set config /section:webFarms /\"[name='#{farm}'].[address='#{server['address']}']\".enabled:true"
    end

    ["-section:webFarms /\"[name='#{farm}'].[address='#{server['address']}']\".applicationRequestRouting.weight:#{server['weight']} /commit:apphost",
     "-section:webFarms /\"[name='#{farm}'].[address='#{server['address']}']\".applicationRequestRouting.httpPort:#{server['port']} /commit:apphost",
     "-section:webFarms /\"[name='#{farm}'].[address='#{server['address']}']\".applicationRequestRouting.httpsPort:#{server['ssl_port']} /commit:apphost"
    ].each do |config_command|
      iis_config config_command
    end
  end

  iis_config "set loadbalancing algorithm for #{farm} to WeightedRoundRobin" do
    cfg_cmd "/section:webFarms /\"[name='#{farm}']\".applicationRequestRouting.loadBalancing.algorithm:WeightedRoundRobin /commit:apphost"
  end

  iis_config "create url rewrite rule for #{farm} web farm" do
    cfg_cmd "-section:system.webServer/rewrite/globalRules /+\"[name='ARR_#{farm}_loadbalance', patternSyntax='Wildcard',stopProcessing='True']\" /commit:apphost"
    not_if "#{ENV['WinDir']}\\System32\\inetsrv\\appcmd.exe set config /section:system.webServer/rewrite/globalRules /\"[name='ARR_#{farm}_loadbalance']\".enabled:true"
  end

  iis_config 'set the url match for the rewrite rule' do
    cfg_cmd "-section:system.webServer/rewrite/globalRules /[name='ARR_#{farm}_loadbalance',patternSyntax='Wildcard',stopProcessing='True'].match.url:\"*\"  /commit:apphost"
  end

  iis_config "route all requests to the #{farm} web farm" do
    cfg_cmd "-section:system.webServer/rewrite/globalRules /[name='ARR_#{farm}_loadbalance',patternSyntax='Wildcard',stopProcessing='True'].action.type:\"Rewrite\" /[name='ARR_#{farm}_loadbalance',patternSyntax='Wildcard',stopProcessing='True'].action.url:\"http://#{farm}/{R:0}\"  /commit:apphost"
  end
end
