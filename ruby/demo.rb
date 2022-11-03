#!/usr/bin/env ruby

require 'yaml'
require 'rexml/document'
require 'byebug'

require './mf_client'

config = YAML.load_file('config.yaml')

mf_client = MFClient.new(
  mf_host: config["mf_host"],
  mf_port: config["mf_port"],
  mf_domain: config["mf_domain"],
  mf_username: config["mf_username"],
  mf_password: config["mf_password"])
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

response_doc = mf_client.mf_post(logon_request_xml)
puts response_doc

session_id = response_doc.elements["response/reply/result/session"].text
# Note: "reply/result" are not in the docs
# puts session_id

ns_list_xml = %Q{<request>
  <service name="asset.namespace.list" session="#{session_id}"/>
</request>}

response_doc = mf_client.mf_post(ns_list_xml)
puts response_doc



logoff_request_xml = %Q{<request>
  <service name="system.logoff" session="#{session_id}"/>
</request>}

response_doc = mf_client.mf_post(logoff_request_xml)
puts response_doc

