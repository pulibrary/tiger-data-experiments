#!/usr/bin/env ruby

require 'yaml'
require 'byebug'

require './mediaflux'

# Load hash with symbolic keys; Avoid extra Rails dependencies for now: 
config = YAML.load_file('config.yaml').map { |k, v| [k.to_sym, v] }.to_h

mf = MediaFlux::MFClient.new(readable: true, verbose: true, **config)

mf.session() do
  # Based on https://docs.google.com/presentation/d/168Cjz8gXy3ESrPnvjATFpcHrcSNFu2x6/edit#slide=id.p122
  mf.list_asset_doc_namespace

  mf.exists_asset_doc_namespace namespace: "foobar"

  # Don't have privs:
  #   user 'library-it:cm757' (id=67) not granted ADMINISTER to service 'asset.doc.namespace.create'
  # doc = mf.create_asset_doc_namespace namespace: "foobar"
  # doc = mf.destroy_asset_doc_namespace namespace: "foobar"


end
