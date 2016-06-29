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

require 'shellwords'

property :name, String, default: 'guix environment'
property :dependent_packages, Array, default: []
property :packages, Array, default: ['coreutils']
property :pure, [TrueClass, FalseClass], default: false
property :container, [TrueClass, FalseClass], default: false
property :network, [TrueClass, FalseClass], default: false
property :share, Array, default: []
property :expose, Array, default: []
property :substitutes, [TrueClass, FalseClass], default: true
property :grafts, [TrueClass, FalseClass], default: true
property :command, String, default: 'true'
property :load_path, Array, default: []
property :cwd, String, default: '/'
property :environment, Hash
property :user, String, default: 'root'
property :group, String, default: 'root'

action :run do
  create_env = [
    'guix',
    'environment',
    load_path.map do |dir|
      "--load-path=#{dir}"
    end,
    dependent_packages,
    '--ad-hoc',
    packages,
    if container
      [
        '--container',
        network ? '--network' : nil,
        expose.map do |(from, to)|
          "--expose=#{from}=#{to}"
        end,
        share.map do |(from, to)|
          "--share=#{from}=#{to}"
        end
      ]
    elsif pure
      '--pure'
    else
      nil
    end,
    if substitutes
      nil
    else
      '--no-substitutes'
    end,
    if grafts
      nil
    else
      '--no-grafts'
    end
  ].flatten.compact.map(&:shellescape).join(' ')

  cmd = if environment
          env_vars = environment.map do |k, v|
            "#{k}=\"#{v.shellescape}\""
          end.join(' ')
          "/bin/sh -c '#{env_vars} #{command}'"
          else
          "/bin/sh -c '#{command}'"
        end

  # These methods are shadowed in the following block.
  dir = cwd
  u = user
  g = group

  execute name do
    command "#{create_env} -- #{cmd}"
    cwd dir
    user u
    group g
  end
end
