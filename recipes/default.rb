#
# Cookbook Name:: iis-lb
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

node['iis-lb']['members'].each do |server|
  iis_lb_server server['address'] do
    weight server['weight']
    port server['port']
    ssl_port server['ssl_port']
  end
end
