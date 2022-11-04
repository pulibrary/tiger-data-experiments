#!/usr/bin/env ruby

require 'yaml'
require 'byebug'

require './mediaflux'

# Load hash with symbolic keys; Avoid extra Rails dependencies for now: 
config = YAML.load_file('config.yaml').map { |k, v| [k.to_sym, v] }.to_h

mf = MediaFlux::MFClient.new(readable: true, **config)

def pretty(doc)
  formatter = REXML::Formatters::Pretty.new
  formatter.compact = true
  formatter.write(doc, "")
end

mf.session() do
  # Based on https://docs.google.com/presentation/d/168Cjz8gXy3ESrPnvjATFpcHrcSNFu2x6/edit#slide=id.p122
  puts "\nList document namespaces:"
  doc = mf.list_asset_doc_namespace
  puts pretty(doc)
  # id = doc.elements["//id"].first

  # puts "\nDelete:"
  # doc = mf.destroy_asset id: id
  # puts doc

  # begin
  #   puts "\nImport asset, data uri FAILS:"
  #   doc = mf.call("asset.import", url: "data:text-plain,hello-world!")
  # rescue MediaFlux::MFError => e
  #   puts e.message
  # end


  # puts doc
  # id = doc.elements["//id"].first

  # puts "\nGet asset:"
  # doc = mf.call("asset.get", id: id)
  # puts doc

  # puts "\nDelete:"
  # doc = mf.call("asset.destroy", id: id)
  # puts doc
end
