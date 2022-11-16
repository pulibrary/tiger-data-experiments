#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require "byebug"

require_relative "mediaflux"

# Load hash with symbolic keys; Avoid extra Rails dependencies for now:
config = YAML.load_file(__dir__ + "/config.yaml").map { |k, v| [k.to_sym, v] }.to_h

mf = MediaFlux::MFClient.new(verbose: true, uses: [:query_asset], **config)

begin
  puts "\nUnknown service:"
  mf.foo_bar
rescue MediaFlux::MFServiceError => service_error
  puts "Error caught! #{service_error}"
end

mf.session do
  doc = mf.list_asset_namespace
  doc.elements["//namespace"].each do |el|
    puts el.text
  end

  # Based on https://docs.google.com/presentation/d/1GAt7tr2Vb-KJtILbcEcMlr71qxVo0j5-/edit#slide=id.p23

  doc = mf.create_asset # name: "dog"
  id = doc.elements["//id"].first

  mf.get_asset id: id

  mf.set_asset id: id, meta: { mf_note: { note: "Hello" } }

  mf.get_asset id: { _version: 1, _: id }

  # Returns nothing. From the example of metadata creation and query ...
  # https://docs.google.com/presentation/d/168Cjz8gXy3ESrPnvjATFpcHrcSNFu2x6/edit#slide=id.p128
  # https://docs.google.com/presentation/d/168Cjz8gXy3ESrPnvjATFpcHrcSNFu2x6/edit#slide=id.p130
  # ... I though the metadata root was also a "type", but that doesn't seem to be true.
  mf.query_asset where: "type='mf-note'"
  mf.query_asset where: "type='mf-note'", action: "get-value", xpath: {_ename: "note", _: "mf-note/note"} 

  mf.destroy_asset id: id
end
