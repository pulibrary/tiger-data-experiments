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

  mf.list_asset_doc_type

  # Don't have privs: (I tried a few different namespaces)
  #  call to service 'asset.doc.type.create' failed: user 'library-it:cm757' (id=67) not granted ADMINISTER to document:namespace 'arc:'
  # doc = mf.create_asset_doc_type(
  #   type: "arc:chuck-demo",
  #   label: "chuck-demo",
  #   definition: {
  #     element_1: {
  #       _name: "name",
  #       _type: "string",
  #       _max_occurs: 1,
  #       _min_occurs: 1
  #     },
  #     element_2: {
  #       _name: "description",
  #       _type: "string",
  #       _max_occurs: 1,
  #       _min_occurs: 1
  #     }
  #   }
  # )
  # id = doc.elements["//id"].first
  # doc = mf.destroy_asset_doc_type id: id


end
