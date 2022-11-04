#!/usr/bin/env ruby

require 'yaml'
require 'byebug'

require './mediaflux'

# Load hash with symbolic keys; Avoid extra Rails dependencies for now: 
config = YAML.load_file('config.yaml').map { |k, v| [k.to_sym, v] }.to_h

mf = MediaFlux::MFClient.new(readable: true, **config)

mf.session() do
  puts "\nList namespaces:"
  doc = mf.list_asset_namespace
  doc.elements["//namespace"].each do |el|
    puts el.text
  end

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
