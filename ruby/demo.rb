#!/usr/bin/env ruby

require 'yaml'
require 'net/http'

config = YAML.load_file('config.yaml')

# Based on curl example from page 14 of "Mediaflux Developer Guide":

request_xml = %Q{<request>
  <service name="system.logon">
    <args>
      <domain>#{config["mf_domain"]}</domain>
      <user>#{config["mf_username"]}</user>
      <password>#{config["mf_password"]}</password>
    </args>
  </service>
</request>}

puts request_xml

https = Net::HTTP.new(config["mf_host"], config["mf_port"])
https.use_ssl = true
https.read_timeout = 3 # I often forget the VPN, so set this low.
https.continue_timeout = 3
request = Net::HTTP::Post.new("__mflux_svc__")
request.body = request_xml
request["Content-Type"] = "text/xml; charset=utf-8"

response = https.request(request)

puts response.body