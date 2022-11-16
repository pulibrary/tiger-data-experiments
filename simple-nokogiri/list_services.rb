# frozen_string_literal: true

require "nokogiri"
require "net/http"
require "yaml"
require "byebug"

require "./connect"

config = YAML.load_file("config.yaml").transform_keys(&:to_sym)
https = Net::HTTP.new(config[:mf_host], config[:mf_port])
https.use_ssl = true

session = login(https, config)
puts "******************** Functions *****************\n\n"
response = build_request(https, session, "function.list")
doc = Nokogiri::XML.parse(response.body)
puts doc.to_xml
puts "\n\n******************** Sevices *****************\n\n"
response = build_request(https, session, "system.service.list")
doc = Nokogiri::XML.parse(response.body)
puts doc.to_xml

response = logoff(https)
puts "Logoff #{response}"
