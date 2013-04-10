# Volume group to create
default['lvm']['vg']['name'] = 'cinder-volumes'
default['lvm']['vg']['pvs'] = [ '/dev/drbd0' ]
default['lvm']['vg']['clustered'] = 'true'
default['lvm']['vg']['lvs'] = nil
