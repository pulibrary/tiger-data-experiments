# frozen_string_literal: true

# call to get a description of a service

require 'nokogiri'
require 'net/http'
require 'yaml'
require 'byebug'

require './connect'

config = YAML.load_file('config.yaml').transform_keys(&:to_sym)
https = Net::HTTP.new(config[:mf_host], config[:mf_port])
https.use_ssl = true

if ARGV.empty?
  puts 'usage: ruby describe_service.rb [service_name]'
  exit
end

session = login(https, config)
response = build_request(https, session, 'system.service.describe')
doc = Nokogiri::XML.parse(response.body)
service_description = doc.xpath("response/reply/result/service[@name='#{ARGV[0]}']")
puts service_description

response = logoff(https)
