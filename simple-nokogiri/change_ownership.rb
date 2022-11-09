# frozen_string_literal: true

require 'nokogiri'
require 'net/http'
require 'yaml'
require 'byebug'
require './connect'

config = YAML.load_file('config.yaml').transform_keys(&:to_sym)
https = Net::HTTP.new(config[:mf_host], config[:mf_port])
https.use_ssl = true

if ARGV.length < 2
  puts 'usage: ruby change_ownership.rb [id(,id)] [new_owner]'
  exit
end

session = login(https, config)
ids = ARGV[0].split(',')
new_owner = ARGV[1]

response = build_request(https, session, 'asset.owner.set') do |xml|
  xml.args do
    xml.domain config[:mf_domain]
    ids.each { |id| xml.id id }
    xml.user new_owner
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
