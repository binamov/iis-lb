#
# Cookbook Name:: iis-lb
# Recipe:: sweep
#
# Copyright (c) 2015 The Authors, All Rights Reserved.
%w( myServerFarm ).each do |farm|
  iis_config "destroy #{farm} web farm" do
    cfg_cmd "-section:webFarms /-\"[name='#{farm}']\" /commit:apphost"
    only_if "#{ENV['WinDir']}\\System32\\inetsrv\\appcmd.exe set config /section:webFarms /\"[name='#{farm}']\".enabled:true"
  end
end
