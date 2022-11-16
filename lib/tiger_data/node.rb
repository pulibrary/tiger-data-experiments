# frozen_string_literal: true

module TigerData
  # Modeling nodes which are ordered sequentially within a List
  class Node
    attr_reader :acl, :id, :leaf, :value, :children

    # @param acl [String] the ACL policy for the node
    # @param id [String] the ID for node
    # @param leaf [String] whether or not this is a leaf node
    # @param value [String] the value for the node
    # @param children [Array<Node>] child nodes for which this is a parent
    def initialize(acl:, id:, leaf:, value:, children: [])
      @acl = acl
      @id = id
      @leaf = leaf
      @value = value
      @children = children
    end

    # Builds the human-readable string representation of the object
    # @return [String]
    def to_s
      "#<#{self.class}: acl: #{acl}, id: #{id}, leaf: #{leaf}, value: #{value}, children: #{children.join(', ')}>"
    end
  end
end
