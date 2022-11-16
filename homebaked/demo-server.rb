#!/usr/bin/env ruby

require 'yaml'
require 'byebug'

require './mediaflux'

# Load hash with symbolic keys; Avoid extra Rails dependencies for now: 
config = YAML.load_file('config.yaml').map { |k, v| [k.to_sym, v] }.to_h

mf = MediaFlux::MFClient.new(verbose: true, use_any_service: true, **config)


mf.session() do
  mf.time_server_clock
  mf.date_server
  mf.describe_server_database
  # mf.list_server_directory # user 'library-it:cm757' (id=67) not granted ADMINISTER to service 'server.directory.list'
  # mf.list_server_environment_variable # user 'library-it:cm757' (id=67) not granted ADMINISTER to service 'server.environment.variable.list'
  mf.log_server app: 'demo', msg: 'arbitrary message!'
  mf.list_server_module
  mf.list_server_peer
  mf.ping_server

  # Definitions for lots of server settings, but without admin privs we can't actually read the values:
  mf.help_server_property 

  # Memory / workers / open files / OS details / etc.
  mf.status_server

  # Lots of "Thread for handling asynchronous background server tasks".
  mf.describe_server_task all: true

  # Just 5 summary numbers.
  mf.statistics_server_task

  doc = mf.create_server_tmp_file
  tmp_path = doc.elements['//path']

  # Not sure if this is the way to read or write files, if we needed to do that... Not sure about mount and uid.
  # mf.open_posix_fs_file for: 'read', path: 'path', mount: '/', uid: my_uid

  # 4.13.031, etc.
  mf.version_server
  # sleep...
  mf.wait_server seconds: 1
  # 1.0
  mf.version_server_xml
end
