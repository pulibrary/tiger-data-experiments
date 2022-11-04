require 'net/http'
require 'rexml/document'

class MFError < StandardError
  attr_reader :error, :message, :stack
  def initialize(response_doc)
    reply = response_doc.elements['/response/reply']
    @error = reply.elements['error'].text
    @message = reply.elements['message'].text
    @stack = reply.elements['stack'].text
  end
end


class MFClient
  def initialize(mf_host:, mf_port:, mf_domain:, mf_username:, mf_password:)
    @mf_host = mf_host
    @mf_port = mf_port
    @mf_domain = mf_domain
    @mf_username = mf_username
    @mf_password = mf_password
  end

  def call(service_name, *xml_args)
    session_attr = @session ? %Q{session="#{@session}"} : ""
    request_xml = %Q{<request>
      <service name="#{service_name}" #{session_attr}>
        <args>#{xml_args.join()}</args>
      </service>
    </request>}
    response = post(request_xml)
    response_type = response.elements["/response/reply/@type"].value
    if response_type == "error" then
      raise MFError.new(response)
    else
      return response
    end
  end

  def session()
    response_doc = call("system.logon", to_xml({
      domain: @mf_domain,
      user: @mf_username,
      password: @mf_password
    }))
    @session = response_doc.elements["response/reply/result/session"].text
    # Note: "reply/result" are not in the docs

    yield

    response_doc = call("system.logoff")
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

# Designed for concise representation of XML fragments as Hashes:
# - Symbolic keys become elements
# - ... unless first charcter is an underscore: then attribute
# - Underscores in names translated to dashes
# - Text can be the value, or can use the "_" key, if there are other attributes.
def to_xml(hash_or_scalar)
  # TODO: Encoding
  return hash_or_scalar unless hash_or_scalar.class == Hash 
  hash_or_scalar.map {|key, value|
    name = key.to_s.sub("_","-")
    if name == "-" then
      value
    elsif name[0] == "-" then
      attr_name = name[1..-1]
      # TODO: Error if not scalar
      # TODO: Encoding
      %Q{ #{attr_name}="#{value}"}
    else
      if value.class == Hash then
        attr_value = value.select {|k,v| k.to_s[0] == '_' and k != :_}
        other_value = value.select {|k,v| k.to_s[0] != '_' or k == :_}
      else
        attr_value = ""
        other_value = value
      end
      "<#{name}#{to_xml(attr_value)}>#{to_xml(other_value)}</#{name}>"
    end
  }.join("")
end