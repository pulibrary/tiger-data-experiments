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
  puts 'usage: ruby create_asset.rb [full file path]'
  exit 1
end

path = ARGV[0]
unless File.exist?(path)
  puts 'file #{path} does not exists'
  exit 1
end

session = login(https, config)

extension = File.extname(path)
input_name = File.basename(path, extension)

name = "#{input_name}_#{Time.now.to_i}.#{extension}"

response = build_request(https, session, 'asset.create',  File.open(path)) do |xml|
  xml.args do
    xml.meta do
      xml.send("mf-name") do
        xml.name name
      end
    end
    xml.name name
    xml.namespace "test"
  end
end
doc = Nokogiri::XML.parse(response.body)
puts doc

response = logoff(https)
