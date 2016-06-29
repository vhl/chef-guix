# GNU Guix cookbook

The Guix cookbook provides access to the functional package management
features of GNU Guix from within Chef recipes.

## Supported Platforms

Any GNU/Linux system will work, but right now Upstart is the only init
system supported.

## Attributes

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['guix']['version']</tt></td>
    <td>String</td>
    <td>GNU Guix release version</td>
    <td><tt>0.10.0</tt></td>
  </tr>
  <tr>
    <td><tt>['guix']['checksum']</tt></td>
    <td>String</td>
    <td>
    The SHA256 checksum of the GNU Guix binary tarball corresponding
    to the appropriate version
    </td>
    <td><tt>0.10.0</tt></td>
  </tr>
  <tr>
    <td><tt>['guix']['substitute_urls']</tt></td>
    <td>Array</td>
    <td>Trusted servers that provide binaries</td>
    <td><tt>['https://mirror.hydra.gnu.org', 'https://hydra.gnu.org']</tt></td>
  </tr>
  <tr>
    <td><tt>['guix']['substitute_keys']</tt></td>
    <td>Array</td>
    <td>Public keys for all substitute servers</td>
    <td>An array with the public key for <tt>hydra.gnu.org</tt></td>
  </tr>
</table>

## Usage

### chef-guix::default

Include `guix` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[guix::default]"
  ]
}
```

## Copyright

Copyright © 2016 Vista Higher Learning, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

See the `LICENSE` file for the full license text.
