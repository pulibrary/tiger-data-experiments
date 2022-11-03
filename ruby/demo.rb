#!/usr/bin/env ruby

require 'yaml'
require 'byebug'

require './mf_client'

# Hash with symbolic keys; Avoid extra Rails dependencies for now: 
config = YAML.load_file('config.yaml').map { |k, v| [k.to_sym, v] }.to_h

mf = MFClient.new(**config)

mf.session() do
  puts "Namespaces:"
  doc = mf.call("asset.namespace.list")
  doc.elements["//namespace"].each do |el|
    puts el.text
  end
end

# response_doc = mf_client.call("asset.namespace.list", session: session)
# puts response_doc


