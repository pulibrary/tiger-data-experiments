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

  earth = mf.create_asset(
    allow_invalid_meta: true, # Because this doesn't conform to "mf_note".
    meta: {mf_note: {name: "Earth", order: 3, moons: 1, gas1: "N2", gas2: "O2"}}
  )
  earth_id = earth.elements["//id"].first

  venus = mf.create_asset(
    allow_invalid_meta: true,
    meta: {mf_note: {name: "Venus", order: 2, moons: 0, gas: "CO2"}}
  )
  venus_id = venus.elements["//id"].first

  mars = mf.create_asset(
    allow_invalid_meta: true,
    meta: {mf_note: {name: "Mars", order: 4, moons: 2, gas: "CO2"}}
  )
  mars_id = mars.elements["//id"].first

  # Error: The document type '' is not known
  # mf.get_asset id: earth_id, xpath: "//gas"

  mf.get_asset id: earth_id

  # No result. :(
  mf.query_asset(
    where: "type=mf-note",
    action: "get-value",
    xpath: "//name" 
  )

  # A list of IDs!
  mf.query_asset(
    where: "xpath(mf-note) has value",
  )

  # Error: The document type 'mf-note' does not contain an element 'moons'
  # mf.query_asset(
  #   where: "xpath(mf-note/moons) has value",
  # )

  mf.destroy_asset id: earth_id
  mf.destroy_asset id: venus_id
  mf.destroy_asset id: mars_id

end
