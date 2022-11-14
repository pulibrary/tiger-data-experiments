# frozen_string_literal: true

module TigerData
  class Cli < Thor
    namespace :tiger_data

    desc "list_assets", "for a given user, list their assets"
    def list_assets
      say("Listing assets...")

      response_document = request_document("asset.namespace.list", "")
      asset_list = List.build(document: response_document)

      say("Assets:")
      say(asset_list)
    end

    # rubocop:disable Metrics/BlockLength
    no_commands do
      # Generate the path to the configuration YAML file
      # @return [String]
      def config_path
        @config_path ||= File.join(__dir__, "..", "..", "config", "media_flux.yaml")
      end

      # Parse the configuration YAML file
      # @return [Hash]
      def config_yaml
        @config_yaml ||= YAML.load_file(config_path)
      end

      # Parse the configuration YAML file into a Hash with symbolized keys
      # @return [Hash]
      def config
        @config ||= config_yaml.map { |k, v| [k.to_sym, v] }.to_h
      end

      # Construct the object for the MediaFlux client
      # @param verbose [Boolean] whether or not verbose logging is enabled for the client
      # @return [MediaFlux::MFClient]
      def client(verbose: false)
        @client ||= MediaFlux::MFClient.new(verbose: verbose, **config)
      end

      # Call a method using the MediaFlux client
      # @param params [Array] parameters for the invocation of MediaFlux#call
      # @return [REXML::Element] the parsed XML response from the API endpoint
      # @raise [MediaFlux::MFError] if the API endpoint returns an error in response to the HTTP request
      def call(*params)
        response_xml_element = client.call(*params)
        response_xml_element
      end

      # Within a session, call a method using the MediaFlux client
      # @param params [Array] parameters for the invocation of MediaFlux#call
      # @return [Nokogiri::Document] the parsed XML response from the API endpoint
      # @raise [MediaFlux::MFError] if the API endpoint returns an error in response to the HTTP request
      def request_document(*params)
        parsed_document = nil

        client.session do
          response_element = call(*params)
          response_document = response_element.document
          response_xml = response_document.to_s

          parsed_document = Nokogiri::XML.parse(response_xml)
          parsed_document
        end

        parsed_document
      end
    end
    # rubocop:enable Metrics/BlockLength
  end
end
