name 'iis-lb'
maintainer 'Bakh Inamov'
maintainer_email 'b@chef.io'
license 'all_rights'
description 'Installs/Configures IIS as a web load-balancer'
long_description 'Creates an IIS Server Farm and adds Servers to the farm.'
version '0.2.6'

supports 'windows'

depends 'webpi', '= 3.0.0'
depends 'iis'
depends 'compat_resource'
