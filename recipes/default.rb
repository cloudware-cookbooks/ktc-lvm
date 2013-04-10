#
# Cookbook Name:: ktc-lvm
# Recipe:: default
#
# Author: Robert Choi <taeilchoi1@gmail.com>
# Copyright 2013 by Robert Choi
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
include_recipe "lvm::default"

package "clvm" do
  action :install
  notifies :create, "ruby_block[backup clvm init script]", :immediately
end

# This block is not really necessary because chef would automatically backup thie file.
# However, it's good to have the backup file in the same directory. (Easier to find later.)
ruby_block "backup clvm init script" do
  block do
      original_pathname = "/etc/init.d/clvm"
      backup_pathname = original_pathname + ".old"
      FileUtils.cp(original_pathname, backup_pathname, :preserve => true)
  end
  action :nothing
  notifies :create, "cookbook_file[/etc/init.d/clvm]", :immediately
end

cookbook_file "/etc/init.d/clvm" do
  source "clvm.init"
  owner "root"
  group "root"
  mode 0755
  action :nothing
  notifies :restart, "service[clvm]", :immediately
end

service "clvm" do
  action :nothing
  notifies :run, "execute[lvmconf --enable-cluster]", :immediately
end

execute "lvmconf --enable-cluster" do
  action :nothing
end

node['lvm']['vg']['pvs'].each do |pv|
  lvm_physical_volume pv
end

lvm_volume_group node['lvm']['vg']['name'] do
  physical_volumes node['lvm']['vg']['pvs']
  notifies :run, "execute[vgchange --clustered y cinder-volumes]", :immediately
end

execute "vgchange --clustered y cinder-volumes" do
  ignore_failure true
  action :nothing
  only_if node['lvm']['vg']['clustered']
end
