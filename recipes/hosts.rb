#
# Cookbook Name:: awscli
# Recipe:: hosts
#
# Copyright 2013, Takayuki SHIMIZUKAWA
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

include_recipe "awscli::default"  #TODO: not need include if aws command provided or not ec2 environment.

env_name = node.my_environment #FIXME: chef-solo (11.4.4) did not support "node.chef_environment" yet.

hosts = Chef::Util::FileEdit.new("/etc/hosts")
bag_name = node.awscli.bag_name
item = data_bag_item(bag_name, env_name)

if item
  item.each do |id, h|
    unless h['ipaddr_aws_private'] || h['ipaddr']
      Chef::Log.warn("data_bags: #{bag_name}/#{env_name} need a ipaddr attribute for '#{id}'.")
      next
    end
    awscli_hosts_entry h['ipaddr'] do
      ipaddr_aws_private h['ipaddr_aws_private']
      hostname id
      aliases h['aliases']
    end
  end
else
  Chef::Log.warn("data_bags: #{bag_name}/#{env_name} did not have '#{env_name}' key.")
end
