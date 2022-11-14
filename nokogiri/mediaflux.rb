# frozen_string_literal: true
require "net/http"
require "rexml/document"
require "nokogiri"

module MediaFlux
  class MFError < StandardError
    attr_reader :error, :message, :stack

    def initialize(response_doc)
      reply = response_doc.elements["/response/reply"]
      @error = reply.elements["error"].text
      @message = reply.elements["message"].text
      @stack = reply.elements["stack"]&.text

      super
    end
  end

  class MFClient
    # rubocop:disable Metrics/ParameterLists
    def initialize(
      mf_host:, mf_port:, mf_domain:, mf_username:, mf_password:, verbose: false
    )
      @verbose = verbose
      @mf_host = mf_host
      @mf_port = mf_port
      @mf_domain = mf_domain
      @mf_username = mf_username
      @mf_password = mf_password
    end
    # rubocop:enable Metrics/ParameterLists

    def call(service_name, args_xml)
      puts "\n#{service_name}: #{args_xml}" if @verbose
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.request do
          xml.service(name: service_name, session: @session) do
            xml.args do
              xml << args_xml
            end
          end
        end
      end
      request_xml = builder.to_xml
      puts request_xml if @verbose
      response = post(request_xml)
      response_type = response.elements["/response/reply/@type"].value
      if response_type == "error"
        raise MediaFlux::MFError, response
      elsif response_type == "result"
        # NOTE: "reply/result" are not in the docs
        result = response.elements["/response/reply/result"]
        puts MediaFlux.pretty result if @verbose
        result
      else
        raise MediaFlux::MFError("Unexpected response type '#{response_type}'")
      end
    end

    def session
      fragment = Nokogiri::XML::DocumentFragment.parse("")
      Nokogiri::XML::Builder.with(fragment) do |xml|
        xml.domain @mf_domain
        xml.user @mf_username
        xml.password @mf_password
      end
      args_xml = fragment.to_xml
      result_doc = call("system.logon", args_xml)
      @session = result_doc.elements["session"].text

      yield

      call("system.logoff", "")
    end

    private

      def post(body)
        https = Net::HTTP.new(@mf_host, @mf_port)
        https.use_ssl = true
        request = Net::HTTP::Post.new("__mflux_svc__")
        request.body = body
        request["Content-Type"] = "text/xml; charset=utf-8"
        response = https.request(request)
        REXML::Document.new(response.body)
      end
  end

  module_function

  def pretty(doc)
    formatter = REXML::Formatters::Pretty.new
    formatter.compact = true
    formatter.write(doc, "")
  end
end
