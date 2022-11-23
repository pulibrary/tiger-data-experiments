# frozen_string_literal: true

require 'nokogiri'
require 'net/http'
require 'yaml'
require 'byebug'

require './connect'

config = YAML.load_file('config.yaml').transform_keys(&:to_sym)
https = Net::HTTP.new(config[:mf_host], config[:mf_port])
https.use_ssl = true

session = login(https, config)

response = build_request(https, session, 'asset.doc.type.list') do |xml|  
              xml.args do
                xml.namespace "*"
              end
            end
doc = Nokogiri::XML.parse(response.body)
puts doc.to_xml

response = logoff(https)
puts "Logoff #{response}"
