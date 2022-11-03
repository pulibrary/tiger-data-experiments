#!/usr/bin/env ruby

require 'yaml'
require 'rexml/document'
require 'byebug'

require './mf_client'

# Hash with symbolic keys, but avoid extra Rails dependencies for now: 
config = YAML.load_file('config.yaml').map { |k, v| [k.to_sym, v] }.to_h

mf_client = MFClient.new(**config)

mf_client.session() do
  response_doc = mf_client.call("asset.namespace.list")
  puts response_doc
end

# response_doc = mf_client.call("asset.namespace.list", session: session)
# puts response_doc


