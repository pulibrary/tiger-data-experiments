#!/usr/bin/env ruby

require 'yaml'
require 'net/http'
require 'rexml/document'
require 'byebug'

def mf_post(mf_host, mf_port, body)
  https = Net::HTTP.new(mf_host, mf_port)
  https.use_ssl = true
  https.read_timeout = 3 # I often forget the VPN, so set this low.
  https.continue_timeout = 3
  request = Net::HTTP::Post.new("__mflux_svc__")
  request.body = body
  request["Content-Type"] = "text/xml; charset=utf-8"
  response = https.request(request)
  response_doc = REXML::Document.new(response.body)
  return response_doc
end

config = YAML.load_file('config.yaml')

# Based on curl example from page 14 of "Mediaflux Developer Guide":

logon_request_xml = %Q{<request>
  <service name="system.logon">
    <args>
      <domain>#{config["mf_domain"]}</domain>
      <user>#{config["mf_username"]}</user>
      <password>#{config["mf_password"]}</password>
    </args>
  </service>
</request>}

# puts request_xml
# request_xml_doc = REXML::Document.new(request_xml)
# puts request_xml_doc.elements["request/service/args/domain"].text

response_doc = mf_post(config["mf_host"], config["mf_port"], logon_request_xml)
puts response_doc

session_id = response_doc.elements["response/reply/result/session"].text
# Note: "reply/result" are not in the docs
# puts session_id

ns_list_xml = %Q{<request>
  <service name="asset.namespace.list" session="#{session_id}"/>
</request>}

response_doc = mf_post(config["mf_host"], config["mf_port"], ns_list_xml)
puts response_doc



logoff_request_xml = %Q{<request>
  <service name="system.logoff" session="#{session_id}"/>
</request>}

response_doc = mf_post(config["mf_host"], config["mf_port"], logoff_request_xml)
# puts response_doc

