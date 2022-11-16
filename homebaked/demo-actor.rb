#!/usr/bin/env ruby

require 'yaml'
require 'byebug'

require './mediaflux'

# Load hash with symbolic keys; Avoid extra Rails dependencies for now: 
config = YAML.load_file('config.yaml').map { |k, v| [k.to_sym, v] }.to_h

mf = MediaFlux::MFClient.new(verbose: true, use_any_service: true, **config)


mf.session() do
  mf.describe_actor_self
  mf.list_actor_type

  # Neither of these return anything, which surprises me. Must be doing it wrong.
  mf.granted_actors role: {_:'user', _type:'role'}
  mf.granted_actors role: {_:'library-it', _type:'domain'}
end
