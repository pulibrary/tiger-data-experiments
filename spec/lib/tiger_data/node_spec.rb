# frozen_string_literal: true

require "spec_helper"

describe TigerData::Node do
  describe "#to_s" do
    let(:acl) { "test" }
    let(:id) { "test" }
    let(:leaf) { true }
    let(:value) { "test" }
    subject(:node) { described_class.new(acl: acl, id: id, leaf: leaf, value: value) }
    it "generates representation of an instance as a String" do
      expect(node.to_s).to eq("#<TigerData::Node: acl: test, id: test, leaf: true, value: test, children: >")
    end
  end
end
