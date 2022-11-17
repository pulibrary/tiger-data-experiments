# frozen_string_literal: true

require 'nokogiri'
require 'net/http'
require 'yaml'
require 'byebug'
require './connect'

config = YAML.load_file('config.yaml').transform_keys(&:to_sym)
https = Net::HTTP.new(config[:mf_host], config[:mf_port])
https.use_ssl = true

if ARGV.length != 3
  puts 'usage: ruby update_metadata.rb [id] [metadata_field] [metadata_value]'
  puts 'valid fields:subject, decription, comments, author, keyword'
  exit 1
end

session = login(https, config)
ids = ARGV[0].split(',')
metadata_field = ARGV[1]
metadata_value = ARGV[2]

response = build_request(https, session, 'asset.set') do |xml|
  xml.args do
    ids.each { |id| xml.id id }
    xml.meta do
      xml.send("mf-document") do
        xml.send( metadata_field, metadata_value)
      end
    end
  end
end
doc = Nokogiri::XML.parse(response.body)
puts doc

response = build_request(https, session, 'asset.get') do |xml|
  xml.args do
    ids.each { |id| xml.id id }
  end
end
doc = Nokogiri::XML.parse(response.body)
puts doc

response = logoff(https)
