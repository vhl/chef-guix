# coding: utf-8
# Cookbook Name:: guix
# Recipe:: default
#
# Copyright © 2016 Vista Higher Learning, Inc.
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

require 'etc'
require 'shellwords'

property :name, String
property :packages, Array
property :profile, String
property :cwd, String, default: '/'
property :load_path, Array, default: []
property :substitutes, [TrueClass, FalseClass], default: true
property :grafts, [TrueClass, FalseClass], default: true
property :user, String, default: 'root'
property :group, String, default: 'root'

def guix_package_cmd(action, resource)
  # Allow installing/removing many packages in one transaction, but
  # support installing a single package easily via the resource name
  # field.
  packages = resource.packages || [resource.name]

  [
    'guix',
    'package',
    action,
    packages,
    resource.load_path.map do |dir|
      "--load-path=#{dir}"
    end,
    if resource.substitutes
      nil
    else
      '--no-substitutes'
    end,
    if resource.grafts
      nil
    else
      '--no-grafts'
    end,
    if resource.profile
      "--profile=#{resource.profile}"
    else
      nil
    end
  ].flatten.compact.map(&:shellescape).join(' ')
end

def environment(user)
  {
    "HOME" => Etc.getpwnam(user).dir,
    "USER" => user
  }
end

action :install do
  dir = cwd
  u = user
  g = group
  e = environment(user)
  execute guix_package_cmd('--install', self) do
    cwd dir
    environment e
    user u
    group g
  end
end

action :remove do
  dir = cwd
  u = user
  g = group
  e = environment(user)
  execute guix_package_cmd('--remove', self) do
    cwd dir
    environment e
    user u
    group g
  end
end
