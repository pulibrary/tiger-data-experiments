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
  doc = mf.call("asset.create", name: "dog")
  puts doc
  id = doc.elements["//id"].first

  puts "\nGet asset:"
  doc = mf.call("asset.get", id: id)
  puts doc

  puts "\nSet metadata:"
  doc = mf.call("asset.set", id: id, meta: {mf_note: {note: "Hello"}})
  puts doc
  
  puts "\nView original:"
  doc = mf.call("asset.get", id: {_version: 1, _: id})
  puts doc

  puts "\nDelete:"
  doc = mf.call("asset.destroy", id: id)
  puts doc

  begin
    puts "\nImport asset by reference FAILS:"
    doc = mf.call("asset.import", url: {
      _by: "reference",
      _: "https://www.princeton.edu/robots.txt"
    })
    # puts doc
    # id = doc.elements["//id"].first

    # puts "\nGet asset:"
    # doc = mf.call("asset.get", id: id)
    # puts doc

    # puts "\nDelete:"
    # doc = mf.call("asset.destroy", id: id)
    # puts doc
  rescue MFError => e
    puts e.message
  end

  begin
    puts "\nImport asset by reference FAILS:"
    doc = mf.call("asset.import", url: {
      _by: "reference",
      _: "https://www.princeton.edu/robots.txt"
    })
    # puts doc
    # id = doc.elements["//id"].first

    # puts "\nGet asset:"
    # doc = mf.call("asset.get", id: id)
    # puts doc

    # puts "\nDelete:"
    # doc = mf.call("asset.destroy", id: id)
    # puts doc
  rescue MFError => e
    puts e.message
  end
end
