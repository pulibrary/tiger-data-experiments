#!/usr/bin/env ruby

require 'yaml'
require 'byebug'

require './mediaflux'

# Load hash with symbolic keys; Avoid extra Rails dependencies for now: 
config = YAML.load_file('config.yaml').map { |k, v| [k.to_sym, v] }.to_h

mf = MediaFlux::MFClient.new(verbose: true, use_any_service: true, **config)


mf.session() do
  # None of these are interesting
  mf.describe_system_cache
  mf.list_system_cache
  mf.list_system_character_encoding

  # Requires admin, but it might be something for a dashboard:
  # mf.describe_system_health_probe

  mf.describe_system_modules
  mf.list_system_modules

  # Works, but I'm not sure what you'd do with a service collection...
  # Maybe give particular users tightly constrained access?
  name = 'asset-services-demo'
  mf.create_system_service_collection include: 'asset\..*\.list', name: name
  mf.describe_system_service_collection name: name
  mf.list_system_service_collection
  mf.destroy_system_service_collection name: name

  # Gets the data that the PDF is built from:
  mf.describe_system_service service: 'system.service.describe'

  mf.put_system_session_map value: {_key: 'name', _: 'chuck'}
  mf.get_system_session_map key: 'name'

  mf.describe_system_session_self
end
