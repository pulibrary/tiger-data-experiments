require 'nokogiri'
require 'net/http'
require 'yaml'
require 'byebug'
require './connect'

config = YAML.load_file('config.yaml').transform_keys(&:to_sym)
https = Net::HTTP.new(config[:mf_host], config[:mf_port])
https.use_ssl = true

if ARGV.length < 1
  puts "usage: ruby show_asset.rb [id(,id)]"
  exit
end

session = login(https, config)
ids = ARGV[0].split(",")

response = build_request(https, session, 'asset.get') do |xml|
  xml.args do
    ids.each {|id| xml.id id}
  end
end
doc = Nokogiri::XML.parse(response.body)
puts doc

response = logoff(https)
