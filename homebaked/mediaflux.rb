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

  class MFServiceError < MFError
  end

  class MFClient
    def initialize(
        verbose: false, uses: [],
        mf_host:, mf_port:, mf_domain:, mf_username:, mf_password:)
      @verbose = verbose
      @mf_host = mf_host
      @mf_port = mf_port
      @mf_domain = mf_domain
      @mf_username = mf_username
      @mf_password = mf_password
      @allowed_services = uses + [
        :logon_system, :logoff_system,
        :list_asset_namespace,
        :create_asset, :get_asset, :set_asset, :destroy_asset
      ]
    end

    def method_missing(service_sym, **args)
      if not @allowed_services.include? service_sym
        raise MediaFlux::MFServiceError.new("'#{service_sym}' is not an allowed service")
      end
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
        raise MediaFlux::MFError.new("Unexpected response type '#{response_type}'")
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
    if hash_or_scalar.class != Hash
      if hash_or_scalar.class != REXML::Document
        return hash_or_scalar.to_s.encode(xml: :text)
      end
      return hash_or_scalar
    end 
    hash_or_scalar.map {|key, value|
      if value.is_a? Array
        value.map {|a_value| to_xml({key => a_value})}.join("")
      else
        name = key.class == String ? key.sub(/^_/, "-") : key.to_s.gsub("_", "-")
        if name == "-" then
          to_xml(value)
        elsif name[0] == "-" then
          attr_name = name[1..-1]
          %Q{ #{attr_name}=#{value.to_s.encode(xml: :attr)}}
        else
          if value.class == Hash then
            non_nil = value.select {|k,v| v != nil}
            attr_other = non_nil.partition {|k,v| (k.to_s[0] == '_' and k != :_)}
            attr_value = Hash[attr_other[0]]
            other_value = Hash[attr_other[1]]
          else
            attr_value = ""
            other_value = value
          end
          "<#{name}#{to_xml(attr_value)}>#{to_xml(other_value)}</#{name}>"
        end
      end
    }.join("")
  end

  def pretty(doc)
    formatter = REXML::Formatters::Pretty.new
    formatter.compact = true
    formatter.write(doc, "")
  end
end