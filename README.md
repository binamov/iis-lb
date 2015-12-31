[![Code Climate](https://codeclimate.com/github/binamov/iis-lb/badges/gpa.svg)](https://codeclimate.com/github/binamov/iis-lb) [![Test Coverage](https://codeclimate.com/github/binamov/iis-lb/badges/coverage.svg)](https://codeclimate.com/github/binamov/iis-lb/coverage)

# iis-lb

This cookbook configures IIS as a simple web load-balancer by creating an IIS Server Farm. It also allows you to add servers to the farm by passing a `node['iis-lb']['members']` hash.

# DISCLAIMER

This cookbook helps demonstrate the `wrapper-cookbook pattern`, `attribute precedence` and `search` in Chef Essentials training for Windows. This cookbook does NOT describe the definitive pattern for configuring IIS as a web load-balancer. Use at your own risk.

# Platforms

This cookbook was tested on:

- Windows Server 2012 R2

It may (or may not) work on other Windows Server variants.

# Usage

Specify your servers by setting the `node['iis-lb']['members']` attribute hash in a wrapper cookbook. Then include the `'iis-lb::default'` recipe. This creates the Server Farm and adds your servers to it. For example:

```
# contents of chef-repo/cookbooks/my-wrapper-cookbook/recipes/default.rb
node.default['iis-lb']['members'] = [
  {
    'address' => 'localhost',
    'weight' => 100,
    'port' => 4000,
    'ssl_port' => 4000
  },
  {
    'address' => '127.0.0.1',
    'weight' => 100,
    'port' => 4001,
    'ssl_port' => 4001
  }]

include_recipe 'iis-lb::default'
```

# Recipes

## default
Installs the necessary components and create an IIS Server Farm `myServerFarm`. This also adds servers to the Server Farm, based on the `node['iis-lb']['members']` attribute hash.

## _arr
Installs Application Request Router (ARR) 3.0 using Microsoft Web Platform Installer (webpi). This recipe is used by the resources in this cookbook.


# Resources

## iis_lb_farm

Creates an IIS Server Farm, sets its load-balancing algorithm and creates the necessary URL rewrite rules.

### Actions
`default` = `:create`

- `:create` - creates the server farm, load balancing algorithm and the URL rewrite rules.
- `:remove` - removes the server farm with all its servers and URL rewrite rules.

### Attribute Parameters

- `farm_name` - the name of the Server Farm.
- `algorithm` - sets the Server Farm's Load Balancing algorithm. Default is `WeightedRoundRobin`, Valid Values are: 'WeightedRoundRobin', 'LeastRequests', 'LeastResponseTime', 'WeightedTotalTraffic', 'RequestHash'

### Example

```
# creates a Server Farm called SuperDuperFarm with lb algorithm LeastRequests
iis_lb_farm 'SuperDuperFarm' do
  action :create
  algorithm 'LeastRequests'
end
```

```
# removes a Server Farm called SuperDuperFarm
iis_lb_farm 'SuperDuperFarm' do
  action :remove
end
```

## iis_lb_server

Adds a server to a Server Farm.

### Actions
`default` = `:add`

- `:add` - adds a server to a server farm. If the specified farm does not exist, it is created automagically. If the farm is not specified then servers get added to a new `myServerFarm`.
- `:remove` - removes a server from a server farm. If the farm is not specified, the server is removed from `myServerFarm`.

### Attribute Parameters

- `server_address` - name attribute. Specifies IP or FQDN of a server to add to the farm.
- `farm` - The name of the IIS Server Farm to add the server to. Default is `myServerFarm`
- `weight` - Relative weight for Weighted Round Robin load distribution. Default is `100`
- `port` - HTTP port that the server is listening on. Default is `80`
- `ssl_port` - HTTPS port that the server is listening on. Default is `443`

### Example

```
# adds server webserver.superdomain.internal, with http/https ports of 8080/4443, to SuperDuperFarm
iis_lb_server 'webserver.superdomain.internal' do
  port 8080
  ssl_port 4443
  farm 'SuperDuperFarm'
  action :add
end
```

```
# removes the Server Farm called SuperDuperFarm
iis_lb_server 'webserver.superdomain.internal' do
  farm 'SuperDuperFarm'
  action :remove
end
```

# Dependencies

This cookbook depends on the following Community Cookbooks:

- webpi
- iis
