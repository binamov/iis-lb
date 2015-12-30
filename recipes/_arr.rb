#
# Cookbook Name:: iis-lb
# Recipe:: _arr
#
# Copyright (c) 2015 The Authors, All Rights Reserved.
include_recipe 'webpi'

webpi_product 'ARRv3_0' do
  accept_eula true
  action :install
end
