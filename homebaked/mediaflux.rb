require 'net/http'
require 'rexml/document'

module MediaFlux

  class MFError < StandardError
  end

  class MFApiError < MFError
    attr_reader :error, :message, :stack
    def initialize(response_doc)
      reply = response_doc.elements['/response/reply']
      @error = reply.elements['error'].text
      @message = reply.elements['message'].text
      @stack = reply.elements['stack']&.text
    end
  end

  class MFXmlError < MFError
  end

  class MFClient
    def initialize(
        verbose: false,
        mf_host:, mf_port:, mf_domain:, mf_username:, mf_password:)
      @verbose = verbose
      @mf_host = mf_host
      @mf_port = mf_port
      @mf_domain = mf_domain
      @mf_username = mf_username
      @mf_password = mf_password
    end

    def method_missing(service_sym, **args)
      service = service_sym.to_s.split("_").rotate.join(".")
      call(service, **args)
    end

    def call(service_name, **args)
      puts "\n#{service_name}: #{args}" if @verbose
      request_xml = MediaFlux.to_xml({
        request: {
          service: {
            _name: service_name,
            _session: @session,
            args: args
          }
        }
      })
      puts request_xml if @verbose
      response = post(request_xml)
      response_type = response.elements["/response/reply/@type"].value
      if response_type == "error" then
        raise MediaFlux::MFApiError.new(response)
      elsif response_type == "result"
        # Note: "reply/result" are not in the docs
        result = response.elements["/response/reply/result"]
        puts MediaFlux.pretty result if @verbose
        return result
      else
        raise MediaFlux::MFError("Unexpected response type '#{response_type}'")
      end
    end

    def session()
      result_doc = logon_system(
        domain: @mf_domain,
        user: @mf_username,
        password: @mf_password
      )
      @session = result_doc.elements["session"].text

      yield

      logoff_system
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

  # Designed for concise representation of XML fragments as Hashes:
  # - Symbolic keys become elements
  # - ... unless first charcter is an underscore: then attribute
  # - Underscores in names translated to dashes
  # - Text can be the value, or can use the "_" key, if there are other attributes.
  def to_xml(hash_or_scalar)
    # TODO: Encoding
    return hash_or_scalar unless hash_or_scalar.class == Hash 
    hash_or_scalar.map {|key, value|
      name = key.to_s.gsub(/[_\d]+$/, "").gsub("_", "-")
      if name == "-" then
        value
      elsif name[0] == "-" then
        attr_name = name[1..-1]
        # TODO: Error if not scalar
        # TODO: Encoding
        %Q{ #{attr_name}="#{value}"}
      else
        if value.class == Hash then
          attr_value = value.select {|k,v| (k.to_s[0] == '_' and k != :_) and v != nil}
          other_value = value.select {|k,v| (k.to_s[0] != '_' or k == :_) and v != nil}
        else
          attr_value = ""
          other_value = value
        end
        "<#{name}#{to_xml(attr_value)}>#{to_xml(other_value)}</#{name}>"
      end
    }.join("")
  end

  def pretty(doc)
    formatter = REXML::Formatters::Pretty.new
    formatter.compact = true
    formatter.write(doc, "")
  end
end