# frozen_string_literal: true

require 'nokogiri'
require 'date'
require 'net/http'
require 'yaml'
require 'byebug'
require './connect'

config = YAML.load_file('config.yaml').transform_keys(&:to_sym)
https = Net::HTTP.new(config[:mf_host], config[:mf_port])
https.use_ssl = true

if ARGV.empty?
  puts 'usage: ruby create_collection.rb [collection name]'
  exit 1
end

collection_name = ARGV[0]

session = login(https, config)

response = build_request(https, session, 'asset.create') do |xml|
  xml.args do
    xml.collection(true, {"record-member-access-time": true })
    xml.meta do
      xml.send("mf-name") do
        xml.name collection_name
      end
    end
    xml.name collection_name
    xml.namespace "test"
  end
end
doc = Nokogiri::XML.parse(response.body)
puts doc

response = logoff(https)
