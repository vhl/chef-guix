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

# This is more-or-less a translation of the official installation
# instructions into a Chef recipe.  See:
# http://www.gnu.org/software/guix/manual/html_node/Binary-Installation.html

arch = node['kernel']['machine']
version = node['guix']['version']
tarball = "guix-binary-#{version}.#{arch}-linux.tar.xz"

remote_file "/tmp/#{tarball}" do
  source "ftp://alpha.gnu.org/gnu/guix/#{tarball}"
  checksum node['guix']['checksum']
  not_if do
    File.exists? '/gnu'
  end
end

# Unpack the binary installation tarball.
execute 'install Guix' do
  command <<-EOF
tar --warning=no-timestamp -xf #{tarball}
mv var/guix /var/ && mv gnu / && rm #{tarball}
EOF
  cwd '/tmp'
  not_if do
    File.exists? '/gnu'
  end
end

# Initialize root user's profile.
link '/root/.guix-profile' do
  to '/var/guix/profiles/per-user/root/guix-profile'
end

# Create build users.
build_users = (1..10).map do |n|
  "guixbuilder#{n}"
end

build_users.each_with_index do |username, n|
  user username do
    shell '/usr/sbin/nologin'
    home '/var/nohome'
    comment "Guix build user #{n + 1}"
    system true
  end
end

group 'guixbuild' do
  system true
  members build_users
end

# Provide the 'guix' command system-wide.
directory '/usr/local/bin' do
  recursive true
end

link '/usr/local/bin/guix' do
  to '/var/guix/profiles/per-user/root/guix-profile/bin/guix'
end

# Authorize binary substitute providers.
ruby_block 'authorize substitutes' do
  block do
    acl = 'etc/guix/acl'

    # Delete the old ACL if there is one.
    if File.exists?(acl)
      File.delete(acl)
    end

    node['guix']['substitute_keys'].each do |key|
      IO.popen('guix archive --authorize', 'w') do |pipe|
        pipe.write(key)
        pipe.close_write
      end

      unless $?.success?
        raise 'guix archive failed'
      end
    end
  end
end

# Start the daemon.
#
# TODO: Support more than just Upstart.
template 'guix-daemon' do
  path '/etc/init/guix-daemon.conf'
  source 'guix-daemon.conf.erb'
  variables substitute_urls: node['guix']['substitute_urls']
  notifies :restart, 'service[guix-daemon]'
end

service 'guix-daemon' do
  supports [:start, :status, :restart]
  action :start
end
