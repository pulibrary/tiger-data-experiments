#!/usr/bin/env ruby

require 'yaml'
require 'byebug'

require './mediaflux'

# Load hash with symbolic keys; Avoid extra Rails dependencies for now: 
config = YAML.load_file('config.yaml').map { |k, v| [k.to_sym, v] }.to_h

mf = MediaFlux::MFClient.new(verbose: true, **config)


begin
  mf.call("foo.bar", "")
rescue MediaFlux::MFError => e
  puts e.error
  puts e.message
end

mf.session() do
  doc = mf.call("asset.namespace.list", "")
  doc.elements["//namespace"].each do |el|
    puts el.text
  end

  # Based on https://docs.google.com/presentation/d/1GAt7tr2Vb-KJtILbcEcMlr71qxVo0j5-/edit#slide=id.p23

  fragment = Nokogiri::XML::DocumentFragment.parse("")
  Nokogiri::XML::Builder.with(fragment) do |xml|
    # xml.name "mouse" # If name is set, and cleanup fails, will not be able to re-run: names are unique.
  end
  args_xml = fragment.to_xml
  doc = mf.call("asset.create", args_xml)
  id = doc.elements["//id"].first

  fragment = Nokogiri::XML::DocumentFragment.parse("")
  Nokogiri::XML::Builder.with(fragment) do |xml|
    xml.id id
  end
  args_xml = fragment.to_xml
  mf.call("asset.get", args_xml)

  fragment = Nokogiri::XML::DocumentFragment.parse("")
  Nokogiri::XML::Builder.with(fragment) do |xml|
    xml.id id
    xml.meta {
      xml.send("mf-note") {
        xml.note "Hello"
      }
    }
  end

  # Element and attribute names with dashes are pretty common in the MediaFlux API.
  # If we do go with Nokogiri, we may want a specialized builder to map these names:
  #
  # def translate(name)
  #   name.gsub("_", "-")
  # end
  #
  # class MFBuilder < Nokogiri::XML::Builder
  #   # MediaFlux xml elements consistently use dashes rather than underscores.
  #   # Since dashes aren't allowed in names in Ruby, translate on the fly.
  #   def method_missing(method, *args)
  #     dashed_method = translate method
  #     dashed_args = args.map {|arg| arg.class == Hash ? Hash[arg.map {|k,v| [translate(k),v]}] : arg}
  #     super(dashed_method, *dashed_args)
  #   end
  # end

  args_xml = fragment.to_xml
  mf.call("asset.set", args_xml)
  
  fragment = Nokogiri::XML::DocumentFragment.parse("")
  Nokogiri::XML::Builder.with(fragment) do |xml|
    xml.id(id, version: 1)
  end
  args_xml = fragment.to_xml
  mf.call("asset.get", args_xml)

  fragment = Nokogiri::XML::DocumentFragment.parse("")
  Nokogiri::XML::Builder.with(fragment) do |xml|
    xml.id id
  end
  args_xml = fragment.to_xml
  mf.call("asset.destroy", args_xml)
end
