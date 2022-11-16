#!/usr/bin/env ruby

require 'yaml'
require 'byebug'

require './mediaflux'

# Load hash with symbolic keys; Avoid extra Rails dependencies for now: 
config = YAML.load_file('config.yaml').map { |k, v| [k.to_sym, v] }.to_h

mf = MediaFlux::MFClient.new(verbose: true, use_any_service: true, **config)


mf.session() do
  mf.list_type
  type = 'text/xyz-demo'
  mf.create_type description: 'demo', type: type, extension: '.demo'
  mf.describe_type type: type
  # How do we specify outputs? Is this something out of band?
  #   service type.script.create requires 1 outputs(s). Requesting 0..0 output(s)
  # mf.create_type_script stype: type
  mf.destroy_type type: type
end
