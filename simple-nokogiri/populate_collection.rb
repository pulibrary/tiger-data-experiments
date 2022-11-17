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
  puts 'usage: ruby populate_collection.rb [collection id] [namespace]'
  exit 1
end

collection_id = ARGV[0]
namespace = ARGV[1]

session = login(https, config)

response = build_request(https, session, 'asset.collection.members.count') do |xml|
  xml.args do
    xml.id collection_id
    xml.send("include-dynamic-members", true)
  end
end
doc = Nokogiri::XML.parse(response.body)
puts "collection count: #{doc}"


response = build_request(https, session, 'asset.collection.members') do |xml|
  xml.args do
    xml.id collection_id
    xml.send("include-dynamic-members", true)
  end
end
doc = Nokogiri::XML.parse(response.body)
puts "collection members: #{doc}"



response = build_request(https, session, 'asset.collection.add') do |xml|
  xml.args do
    xml.id collection_id
    xml.where "namespace='/#{namespace}' and not (asset in collection #{collection_id}) and not (id=#{collection_id})"
  end
end
doc = Nokogiri::XML.parse(response.body)
puts doc

response = logoff(https)
