# frozen_string_literal: true

module TigerData
  class List
    # @param document [Nokogiri::XML::Document] the XML document response from the API endpoint
    # @return [Nokogiri::XML::Element] the XML element containing the <result> fragment
    def self.find_result_element(document:)
      response_element = document.at_xpath("/response")
      reply_element = response_element.at_xpath("./reply")
      result_element = reply_element.at_xpath("./result")

      result_element
    end

    # @param element [Nokogiri::XML::Element] the XML element containing the root element for the list tree
    # @return [Nokogiri::XML::Element] the XML element containing the <namespace> fragment
    def self.find_root_element(element:)
      root_element = element.at_xpath("./namespace[@path='/']")

      root_element
    end

    # @param root_element [Nokogiri::XML::Element] the XML element containing the ordered child nodes for the list tree
    # @return [Array<Node>] the child nodes for the list tree
    def self.build_nodes(root_element:)
      elements = root_element.xpath("./namespace")
      built = elements.map do |element|
        leaf = element["leaf"] == "true"
        children = if leaf
                     []
                   else
                     build_nodes(root_element: element)
                   end

        Node.new(acl: element["acl"], id: element["id"], leaf: leaf, value: element.text, children: children)
      end

      built
    end

    # @param document [Nokogiri::XML::Document] the XML document response from the API endpoint
    # @return [TigerData::List] the newly-constructed List object
    def self.build(document:)
      result_element = find_result_element(document: document)
      root_element = find_root_element(element: result_element)
      nodes = build_nodes(root_element: root_element)

      new(nodes: nodes)
    end

    include Enumerable
    attr_reader :nodes

    # @param nodes [Array<Node>] the member nodes ordered sequentially for this list
    def initialize(nodes:)
      @nodes = nodes
    end

    # Iterate over the child nodes (this implements the interface for Enumerable)
    # @return [Enumerable]
    def each
      nodes.each { |node| yield node }
    end

    # Builds the human-readable string representation of the object
    # @return [String]
    def to_s
      "#<#{self.class}: nodes: #{to_a.join(', ')}>"
    end
  end
end
