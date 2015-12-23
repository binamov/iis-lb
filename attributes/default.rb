default['iis-lb']['members'] = [{
  'address' => 'localhost',
  'weight' => 100,
  'port' => 4000,
  'ssl_port' => 4000
}, {
  'address' => '127.0.0.1',
  'weight' => 100,
  'port' => 4001,
  'ssl_port' => 4001
}]
