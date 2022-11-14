#!/usr/bin/env ruby

require 'yaml'
require 'byebug'

require './mediaflux'

# Load hash with symbolic keys; Avoid extra Rails dependencies for now: 
config = YAML.load_file('config.yaml').map { |k, v| [k.to_sym, v] }.to_h

mf = MediaFlux::MFClient.new(verbose: true, use_any_service: true, **config)


mf.session() do
  # Caching and journaling configs:
  mf.describe_xodb_live_config
  # Not interesting:
  mf.objects_xodb_query_cache_largest
  # Everything else is admin-only.
end
