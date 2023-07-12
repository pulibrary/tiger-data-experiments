# frozen_string_literal: true

require 'nokogiri'
require 'net/http'
require 'yaml'
require 'byebug'

require './connect'

config = YAML.load_file('config.yaml').transform_keys(&:to_sym)
https = Net::HTTP.new(config[:mf_host], config[:mf_port])
https.use_ssl = true


if ARGV.count < 2
  puts "usage: ruby add_collection_meta.rb [id] [metdata_tag] [(optional) default value]"
  puts " for example 'ruby add_collection_meta.rb 123 mf-forum-topic <topic>topic</topic><participant/>'"
  exit
end

id = ARGV[0]
metdata_tag = ARGV[1]
default_value = ARGV[2]

session = login(https, config)

response = build_request(https, session, 'asset.doc.type.describe') do |xml|  
  xml.args do
    xml.type metdata_tag
  end
end    
doc = Nokogiri::XML.parse(response.body)
puts doc.to_xml

puts "\n\n******************** Collection #{id} *****************\n\n"
# To create a new metadata template you should be able to run "asset.doc.type.create" service
#  At the moment I do not have the permissions to create one
response = build_request(https, session, 'asset.collection.member.template.add') do |xml|  
  xml.args do
    xml.id id
    xml.send("member-template") do
      xml.metadata do
        xml.definition(metdata_tag, {requirement: "optional"})
        unless default_value.nil?
          xml.value do
            xml << default_value
          end
        end
      end
    end
  end
end
doc = Nokogiri::XML.parse(response.body)
puts doc.to_xml

response = logoff(https)
puts "Logoff #{response}"
