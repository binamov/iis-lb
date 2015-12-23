[![Code Climate](https://codeclimate.com/github/binamov/iis-lb/badges/gpa.svg)](https://codeclimate.com/github/binamov/iis-lb)

# iis-lb

This cookbook configures IIS as a simple web load-balancer by creating an IIS Server Farm. It also allows you to pass a `node['iis-lb']['members']` hash to add servers to the said server farm.

## Platforms

This cookbook was tested on:

- Windows Server 2012 R2

## Usage

Adding ` recipe['iis-lb::default'] ` to your Windows Server's `run_list` will install all the necessary components and set the node up with a Server Farm `myServerFarm`. This will also add two servers to the Server Farm, based on the `node['iis-lb']['members']` hash. One should override this hash to add their own servers to the farm, such as in this example wrapper recipe:
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
