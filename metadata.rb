name              "ktc-lvm"
maintainer        "Robert Choi"
license           "Apache 2.0"
description       "Installs clvm package and creates pv, vg and lvs" 
version           "0.9.0"

recipe "default", "Installs clvm package and creates pv, vg and lvs"

%w{ redhat centos debian ubuntu }.each do |os|
  supports os
end

depends "lvm"
