#
# Cookbook Name:: awscli
# Provider:: hosts_entry
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

# Support whyrun
def whyrun_supported?
  true
end

def load_current_resource
  @ip_address = new_resource.ip_address
  @hostname = new_resource.hostname
  @aliases = new_resource.aliases
  @comment = new_resource.comment
  @priority = new_resource.priority
  @unique = new_resource.unique

  if new_resource.ipaddr_aws_private
    @ip_address = load_aws_private_ipaddrs[@hostname]
  end
  unless @ip_address
    Chef::Log.warn("data_bags: hosts.json #{h['id']} want use ipaddr_aws_private, but aws IP address can't detect.")
  end
end


# Creates a new hosts file entry. If an entry already exists, it will be
# overwritten by this one.
action :create do
  if hostsfile.contains?(new_resource)
    Chef::Log.debug "#{new_resource} already exists - overwriting."
  end

  converge_by("Create #{new_resource}") do
    hostsfile.add(
      ip_address: @ip_address,
      hostname:   @hostname,
      aliases:    @aliases,
      comment:    @comment,
      priority:   @priority,
      unique:     @unique,
    )
  end
end

# Create a new hosts file entry, only if one does not already exist for
# the given IP address. If one exists, this does nothing.
action :create_if_missing do
  if hostsfile.contains?(new_resource)
    Chef::Log.info "#{new_resource} already exists - skipping create_if_missing."
  else
    converge_by("Create #{new_resource} if missing") do
      hostsfile.add(
        ip_address: @ip_address,
        hostname:   @hostname,
        aliases:    @aliases,
        comment:    @comment,
        priority:   @priority,
        unique:     @unique,
      )
    end
  end
end

# Appends the given data to an existing entry. If an entry does not exist,
# one will be created
action :append do
  unless hostsfile.contains?(new_resource)
    Chef::Log.info "#{new_resource} does not exist - creating instead."
  end
  converge_by("Append #{new_resource}") do
    hostsfile.append(
      ip_address: @ip_address,
      hostname:   @hostname,
      aliases:    @aliases,
      comment:    @comment,
      priority:   @priority,
      unique:     @unique,
    )
  end
end

# Updates the given hosts file entry. Does nothing if the entry does not
# exist.
action :update do
  if hostsfile.contains?(new_resource)
    converge_by("Update #{new_resource}") do
      hostsfile.update(
        ip_address: @ip_address,
        hostname:   @hostname,
        aliases:    @aliases,
        comment:    @comment,
        priority:   @priority,
        unique:     @unique,
      )
    end
  else
    Chef::Log.info "#{new_resource} does not exist - skipping update."
  end
end

# Removes an entry from the hosts file. Does nothing if the entry does
# not exist.
action :remove do
  if hostsfile.contains?(new_resource)
    converge_by("Remove #{new_resource}") do
      hostsfile.remove(@ip_address)
    end
  else
    Chef::Log.info "#{new_resource} does not exist - skipping remove."
  end
end

private
  # The hostsfile object
  #
  # @return [Manipulator]
  #   the manipulator for this hostsfile
  def hostsfile
    @hostsfile ||= Manipulator.new(node)
  end

  def load_aws_private_ipaddrs()
    env_name = node.my_environment #FIXME: chef-solo (11.4.4) did not support "node.chef_environment" yet.
    aws_private_ipaddrs = {}
    if node[:aws]
      node.aws.ec2.instances.each do |i|
        tags = {}
        i['Tags'].each do |tag|
          tags[tag['Key']] = tag['Value']
        end

        ipaddr = i['PrivateIpAddress']
        name = tags[node.awscli.aws_tag_name_hostid]
        unless ipaddr.nil? || name.nil? || tags[node.awscli.aws_tag_name_environment] != env_name
          aws_private_ipaddrs[name] = ipaddr
        end
      end
    else
      Chef::Log.warn("AWS ohai plugin not supported.")
    end
    aws_private_ipaddrs
  end

