#
# Cookbook Name:: awscli
# Definition:: install_awscli
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


define :install_awscli, :action => :install, :owner => 'root', :group => 'root', :home_path => nil do
  owner = params[:owner]
  group = params[:group]
  home_path = params[:home_path] || if owner == 'root'
    '/root'
  else
    "/home/#{owner}"
  end

  ez_setup_path = "#{Chef::Config[:file_cache_path]}/ez_setup.py"
  easy_install_cmd = "#{home_path}/.local/bin/easy_install"
  virtualenv_cmd = "#{home_path}/.local/bin/virtualenv"
  aws_env_path = "#{home_path}/.aws"
  aws_conf_path = "#{aws_env_path}/config"
  aws_pip_cmd = "#{aws_env_path}/bin/pip"
  aws_cmd = "#{aws_env_path}/bin/aws"
  ohai_plugins_path = "#{home_path}/.ohai_plugins"
  unless Ohai::Config[:plugin_path].include?(ohai_plugins_path)
    Ohai::Config[:plugin_path] = [ohai_plugins_path, Ohai::Config[:plugin_path]].flatten.compact
  end

  if node.awscli.aws_command_path.nil?
    node.set['awscli']['aws_command_path'] = aws_cmd
  end

  case params[:action]
  when :install

    remote_file ez_setup_path do
      action :create_if_missing
      source "https://bitbucket.org/pypa/setuptools/raw/bootstrap/ez_setup.py"
      not_if {File.exists?(easy_install_cmd)}
    end

    execute "python #{ez_setup_path} --user" do
      environment ({"HOME" => "/root"})
      not_if {File.exists?(easy_install_cmd)}
    end

    execute "#{easy_install_cmd} virtualenv" do
      environment ({"HOME" => "/root"})
      not_if {File.exists?(virtualenv_cmd)}
    end

    execute "#{virtualenv_cmd} #{aws_env_path}" do
      not_if {File.exists?(aws_cmd)}
    end

    execute "#{aws_pip_cmd} install awscli" do
      not_if {File.exists?(aws_cmd)}
    end

    directory "#{ohai_plugins_path}" do
      owner owner
      group group
    end

    template "#{ohai_plugins_path}/aws.rb" do
      source 'ohai_plugin_aws.rb.erb'
      owner owner
      group group
      variables ({
        :aws_access_key_id     => node.awscli.aws_access_key_id,
        :aws_secret_access_key => node.awscli.aws_secret_access_key,
        :aws_default_region    => node.awscli.aws_default_region,
        :aws_command_path      => node.awscli.aws_command_path,
      })
    end

    ohai 'reload' do
      action :reload
      plugin 'aws'
    end

  end

end
