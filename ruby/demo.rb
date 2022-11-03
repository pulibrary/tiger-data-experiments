#!/usr/bin/env ruby

require 'yaml'
require 'rexml/document'
require 'byebug'

require './mf_client'

# Hash with symbolic keys, but avoid extra Rails dependencies for now: 
config = YAML.load_file('config.yaml').map { |k, v| [k.to_sym, v] }.to_h

mf_client = MFClient.new(**config)

response_doc = mf_client.call("system.logon",
  "<domain>#{config[:mf_domain]}</domain>",
  "<user>#{config[:mf_username]}</user>",
  "<password>#{config[:mf_password]}</password>",
)

puts response_doc

session = response_doc.elements["response/reply/result/session"].text
# Note: "reply/result" are not in the docs

response_doc = mf_client.call("asset.namespace.list", session: session)
puts response_doc

response_doc = mf_client.call("system.logoff", session: session)
puts response_doc

