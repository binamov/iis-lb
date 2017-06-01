#
# Cookbook:: iis-lb
# Recipe:: disable_cache.rb
#
# Copyright:: 2017, The Authors, All Rights Reserved.

powershell_script 'myServerFarm_disable_disk_cache' do
  code <<-EOH
    $filter = "/webFarms/webFarm[@name='myServerFarm']/applicationRequestRouting/protocol/cache"
    $path = 'MACHINE/WEBROOT/APPHOST'
    Set-WebConfigurationProperty -PSPath $path -Filter $filter -Name 'enabled' -Value 'False'
  EOH
end

powershell_script 'myServerFarm_set_cache_interval' do
  code <<-EOH
    $filter = "/webFarms/webFarm[@name='myServerFarm']/applicationRequestRouting/protocol/cache"
    $path = 'MACHINE/WEBROOT/APPHOST'
    Set-WebConfigurationProperty -PSPath $path -Filter $filter -Name 'validationInterval' -Value '00:00:00'
  EOH
end
