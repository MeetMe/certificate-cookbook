Certificate Cookbook
====================
This cookbook contains LWRPs for creating and deleting SSL Certificates stored
in a data bag named "certificates".

When used, the fully qualified hostname (`foo.bar.com` not just `foo`) for the
certificate is passed into the LWRP block and all items in the data bag are
checked to see if their certificates would cover the hostname. The first data bag
to have a matching item in its `valid_hostname` is used.

This is behavior is achieved by checking the `valid_hostnames` array for both
the hostname passed in and the short hostname (`foo` in `foo.bar.com`) replaced
with `*` to find any wildcard domain matches.  For example, `foo.bar.com` would
match any certificate in all data bag items with a `valid_hostnames` item value
of `foo.bar.com` or `*.bar.com`

The `:create` action will by default create the certificate file, the key file,
and if specified, the cacert file using the following format:

 - `node[:certificate][:directory]/filtered_hostname.cert.pem`
 - `node[:certificate][:directory]/filtered_hostname.key.pem`
 - `node[:certificate][:directory]/filtered_hostname.cacert.pem`

The `filtered_hostname` value is filtered by the following regex:

    /^(\*\.|)([\w\-_\.]+)$/

And would yield the following values:

<table>
  <tr>
    <th>Hostname</th>
    <th>Filtered</th>
  </tr>
  <tr>
    <td>foo.bar.com</td>
    <td>foo.bar.com</td>
  </tr>
  <tr>
    <td>*.bar.com</td>
    <td>bar.com</td>
  </tr>
</table>

The certificate file for `foo.bar.com` with a default SSL path of
`/etc/ssl/certs` would be:

    /etc/ssl/certs/foo.bar.com.cert.pem

Data bag item format
--------------------
The data bag item has the following format:

 - id: The data bag item id
 - certificate: A string containing the certificate
 - key: A string containing the certificate key
 - valid_hostnames: An array of strings containing valid hostnames for the certificate
 - cacert: An optional CA certificate (or chained certificates)
 - issued: Currently for informational purposes only, a string containing the timestamp for when the certificate was created
 - expiration: Currently for informational purposes only, a string containing the timestamp for when the certificate expires

The `certificate`, `key` and `valid_hostname` values are required.

    {
      "id": "some-value",
      "certificate": "-----BEGIN CERTIFICATE-----\nCERT VALUE\n-----END CERTIFICATE-----\n",
      "key": "-----BEGIN RSA PRIVATE KEY-----\nKEY-VALUE\n-----END RSA PRIVATE KEY-----\n",
      "valid_hostnames": ["some-domain.net", "*.some-domain.net"],
      "cacert": "-----BEGIN CERTIFICATE-----\nCA CERT VALUE - CAN BE CHAINED CERTS\n-----END CERTIFICATE-----\n",
      "issued": "Sep 18 00:10:52 2013 GMT",
      "expiration": "Sep 18 00:10:52 2023 GMT"
    }

Usage
-----

Create the certificate files for the hostname foo.bar.com to the default path:

    certificate_files 'foo.bar.com' do
        action :create
    end

Create the certificate files for the hostname foo.bar.com to an alternate path:

    certificate_files 'foo.bar.com' do
        action :create
        path '/some/other/path'
    end

Remove installed certificate files from the default path:

    certificate_files 'foo.bar.com' do
        action :delete
    end

Attributes
----------

#### certificate::default
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>[:certificate][:directory]</tt></td>
    <td>String</td>
    <td>Path to install certificates in by default</td>
    <td>/etc/ssl/certs</td>
  </tr>
</table>


License and Author
------------------
Author:: Gavin M. Roy (gmr@meetme.com) Copyright:: 2013, MeetMe, Inc

Copyright (c) 2013, MeetMe, Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.
 * Neither the name of the MeetMe, Inc. nor the names of its
   contributors may be used to endorse or promote products derived from this
   software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.