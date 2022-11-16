#!/usr/bin/env ruby

require 'yaml'
require 'byebug'

require './mediaflux'

# Load hash with symbolic keys; Avoid extra Rails dependencies for now: 
config = YAML.load_file('config.yaml').map { |k, v| [k.to_sym, v] }.to_h

mf = MediaFlux::MFClient.new(verbose: true, use_any_service: true, **config)


mf.session() do
  # Unlike other resources, there are no create and destroy methods
  mf.list_uniqueid
  mf.next_uniqueid name: 'demo'
  mf.next_uniqueid name: 'demo'
  mf.describe_uniqueid name: 'demo'
end
