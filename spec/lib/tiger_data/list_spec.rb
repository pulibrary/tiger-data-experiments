# frozen_string_literal: true

require "spec_helper"

describe TigerData::List do
  let(:acl) { "test" }
  let(:id) { "test" }
  let(:leaf) { true }
  let(:value) { "test" }
  let(:node) { TigerData::Node.new(acl: acl, id: id, leaf: leaf, value: value) }
  let(:node2) { TigerData::Node.new(acl: acl, id: id, leaf: leaf, value: value) }
  let(:nodes) { [node, node2] }
  subject(:list) { described_class.new(nodes: nodes) }

  describe ".build" do
    let(:element3) { instance_double(Nokogiri::XML::Element) }

    let(:element2) { instance_double(Nokogiri::XML::Element) }
    # let(:element2) { double('test') }
    let(:element) { instance_double(Nokogiri::XML::Element) }
    let(:elements) { [element, element2] }
    let(:root) { instance_double(Nokogiri::XML::Element) }

    let(:reply) { instance_double(Nokogiri::XML::Element) }
    let(:result) { instance_double(Nokogiri::XML::Element) }
    let(:response) { instance_double(Nokogiri::XML::Element) }
    let(:document) { instance_double(Nokogiri::XML::Document) }
    subject(:list) { described_class.build(document: document) }

    before do
      allow(element3).to receive(:[]).with("leaf").and_return("true")
      allow(element3).to receive(:text).and_return("test")
      allow(element3).to receive(:[]).with("value").and_return("test")
      allow(element3).to receive(:[]).with("id").and_return("test")
      allow(element3).to receive(:[]).with("acl").and_return("test")

      allow(element2).to receive(:xpath).and_return([element3])
      allow(element2).to receive(:text).and_return("test")
      allow(element2).to receive(:[]).with("leaf").and_return("false")
      allow(element2).to receive(:[]).with("value").and_return("test")
      allow(element2).to receive(:[]).with("id").and_return("test")
      allow(element2).to receive(:[]).with("acl").and_return("test")

      allow(element).to receive(:text).and_return("test")
      allow(element).to receive(:[]).with("leaf").and_return("true")
      allow(element).to receive(:[]).with("value").and_return("test")
      allow(element).to receive(:[]).with("id").and_return("test")
      allow(element).to receive(:[]).with("acl").and_return("test")

      allow(root).to receive(:xpath).and_return(elements)
      allow(result).to receive(:at_xpath).and_return(root)
      allow(reply).to receive(:at_xpath).and_return(result)
      allow(response).to receive(:at_xpath).and_return(reply)
      allow(document).to receive(:at_xpath).and_return(response)
    end

    it "constructs a new List object" do
      expect(list).to be_a(TigerData::List)
      expect(list.to_s).to eq("#<TigerData::List: nodes: #<TigerData::Node: acl: test, id: test, leaf: true, value: test, children: >, #<TigerData::Node: acl: test, id: test, leaf: false, value: test, children: #<TigerData::Node: acl: test, id: test, leaf: true, value: test, children: >>>")
    end
  end

  describe "#each" do
    it "enumerates through the sequentially-ordered nodes" do
      expect(list.each).to be_an(Enumerable)
      expect(list.each.to_a).to eq(nodes)
    end
  end

  describe "#to_s" do
    it "generates representation of an instance as a String" do
      expect(list.to_s).to eq("#<TigerData::List: nodes: #<TigerData::Node: acl: test, id: test, leaf: true, value: test, children: >, #<TigerData::Node: acl: test, id: test, leaf: true, value: test, children: >>")
    end
  end
end
