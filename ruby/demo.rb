#!/usr/bin/env ruby

require 'yaml'
require 'net/http'

config = YAML.load_file('config.yaml')
puts(config)

# Net::HTTP.get('example.com', '/index.html')