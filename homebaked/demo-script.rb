#!/usr/bin/env ruby

require 'yaml'
require 'byebug'

require './mediaflux'

# Load hash with symbolic keys; Avoid extra Rails dependencies for now: 
config = YAML.load_file('config.yaml').map { |k, v| [k.to_sym, v] }.to_h

mf = MediaFlux::MFClient.new(verbose: true, use_any_service: true, **config)


mf.session() do
  # <result>
  #   <standard-output>Hello World! </standard-output>
  # </result>
  mf.execute_script script: 'puts "Hello\nWorld!"', standard_output_to: "response"
  
  # <result>
  #   <result>
  #     &lt;result&gt;&lt;date ...
  #   </result>
  # </result>
  mf.execute_script script: 'server.date', standard_output_to: "response"

  # <result>
  #   <standard-output>
  #     :date ...
  #   </standard-output>
  #   <result>
  #     &lt;result&gt;&lt;date ...
  #   </result>
  # </result>
  mf.execute_script script: 'server.date', standard_output_to: "response", verbose: true

  # <result>
  #   <result>
  #     &lt;result&gt;&lt;date ...
  #   </result>
  # </result>
  mf.execute_script script: 'server.date', verbose: true

  # <result>
  #   <result xml='true'>
  #     <date tz='America/New_York' ...
  #   </result>
  # </result>
  mf.execute_script script: 'server.date', verbose: true, output_format: "xml"

  # <result>
  #   <standard-output>
  #     <line>
  #       <date tz='America/New_York' ...
  #     </line>
  #   </standard-output>
  #   <result>
  #     &lt;result&gt;&lt;date ...
  #   </result>
  # </result>
  mf.execute_script script: 'server.date', standard_output_to: "response", verbose: true, enclose_output_in_xml: true
end
