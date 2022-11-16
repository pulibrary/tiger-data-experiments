#!/usr/bin/env ruby

require 'yaml'
require 'byebug'

require './mediaflux'

# Load hash with symbolic keys; Avoid extra Rails dependencies for now: 
config = YAML.load_file('config.yaml').map { |k, v| [k.to_sym, v] }.to_h

mf = MediaFlux::MFClient.new(verbose: true, use_any_service: true, **config)


mf.session() do
  mf.list_user domain: 'library-it'
  mf.get_user domain: 'library-it', user: 'cm757'
  mf.describe_user domain: 'library-it', user: 'cm757'
  # Or more simply in this case:
  mf.get_user_self
  mf.list_user_self_settings
  mf.set_user_self_settings app: 'abc', settings: { doc: 'hello world?' }
  mf.get_user_self_settings app: 'abc'
  # call to service 'user.create' failed: user 'library-it:cm757' (id=67) not granted ADMINISTER to authentication:domain 'library-it'
  # mf.create_user domain: 'library-it', user: 'demo'
  # mf.destroy_user domain: 'library-it', user: 'demo'
end
