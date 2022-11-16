#!/usr/bin/env ruby

require 'yaml'
require 'byebug'

require './mediaflux'

# Load hash with symbolic keys; Avoid extra Rails dependencies for now: 
config = YAML.load_file('config.yaml').map { |k, v| [k.to_sym, v] }.to_h

mf = MediaFlux::MFClient.new(verbose: true, use_any_service: true, **config)


mf.session() do
  mf.list_dictionary # returns nothing
  mf.get_dictionary_default # returns "default"
  mf.describe_dictionary name: "default" # empty
  # mf.list_dictionary_entries: # call to service 'dictionary.entries.list' failed: The dictionary 'default' does not exist
  # mf.create_dictionary name: "mccalluc-test" # call to service 'dictionary.create' failed: No permission to create dictionary within global dictionary namespace.
  # mf.add_dictionary_entry term: "demo" # call to service 'dictionary.entry.add' failed: The dictionary 'default' does not exist.
  # mf.create_dictionary_namespace namespace: "demo" # user 'library-it:cm757' (id=67) not granted ADMINISTER to service 'dictionary.namespace.create'
end
