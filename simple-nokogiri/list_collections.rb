# frozen_string_literal: true

require 'nokogiri'
require 'net/http'
require 'yaml'
require 'byebug'

require './connect'

config = YAML.load_file('config.yaml').transform_keys(&:to_sym)
https = Net::HTTP.new(config[:mf_host], config[:mf_port])
https.use_ssl = true

ids = nil
if ARGV.length >= 1
  ids = ARGV[0].split(",")
end
  

session = login(https, config)
puts "\n\n******************** Collections #{ids} *****************\n\n"
response = build_request(https, session, 'asset.namespace.list') do |xml|
    if !ids.nil?
        xml.args do
            xml.assets = true
            ids.each {|id| xml.id id}
        end
    end
end
doc = Nokogiri::XML.parse(response.body)
puts doc.to_xml

response = logoff(https)
puts "Logoff #{response}"
