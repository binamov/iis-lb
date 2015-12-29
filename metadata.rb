name 'iis-lb'
maintainer 'Bakh Inamov'
maintainer_email 'b@chef.io'
license 'all_rights'
description 'Installs/Configures IIS as a web load-balancer'
long_description 'Creates an IIS Server Farm and adds Servers to the farm.'
version '0.1.13'

supports 'windows'

depends 'webpi'
depends 'iis'
