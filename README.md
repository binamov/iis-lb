# iis-lb

This cookbook configures IIS as a simple web load-balancer by creating an IIS Server Farm. It also allows you to pass a `node['iis-lb']['members']` hash to add servers to the said server farm.

## Example usage

In a wrapper recipe:
```
node.default['iis-lb']['members'] = [{
  "address" => "localhost",
  "weight" => 100,
  "port" => 80,
  "ssl_port" => 443
}, {
  "address" => "127.0.0.1",
  "weight" => 100,
  "port" => 80,
  "ssl_port" => 443
}]

include_recipe 'iis-lib'
```

## Dependencies

This cookbook depends on the following Community Cookbooks:

- windows
- webpi
- iis
