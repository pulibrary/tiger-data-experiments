#!/usr/bin/env ruby

require 'yaml'
require 'byebug'

require './mf_client'

# Hash with symbolic keys; Avoid extra Rails dependencies for now: 
config = YAML.load_file('config.yaml').map { |k, v| [k.to_sym, v] }.to_h

mf = MFClient.new(**config)


begin
  puts "\nUnknown service:"
  mf.call("foo.bar")
rescue MFError => e
  puts e.error
  puts e.message
  puts e.stack.split("\n").first
end

mf.session() do
  puts "\nList namespaces:"
  doc = mf.call("asset.namespace.list")
  doc.elements["//namespace"].each do |el|
    puts el.text
  end

  # Based on https://docs.google.com/presentation/d/1GAt7tr2Vb-KJtILbcEcMlr71qxVo0j5-/edit#slide=id.p23
  puts "\nCreate asset:"
  doc = mf.call("asset.create", "<name>dog</name>")
  puts doc
  id = doc.elements["//id"].first

  puts "\nGet asset:"
  doc = mf.call("asset.get", "<id>#{id}</id>")
  puts doc

  puts "\nSet metadata:"
  doc = mf.call("asset.set", "<id>#{id}</id>",
    "<meta><mf-note><note>Hello</note></mf-note></meta>")
  puts doc
  
  puts "\nView original:"
  doc = mf.call("asset.get", %Q{<id version="1">#{id}</id>})
  puts doc

  puts "\nDelete:"
  doc = mf.call("asset.destroy", %Q{<id>#{id}</id>})
  puts doc
end

# response_doc = mf_client.call("asset.namespace.list", session: session)
# puts response_doc


