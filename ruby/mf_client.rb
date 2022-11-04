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
    response_doc = call("system.logon",
      "<domain>#{@mf_domain}</domain>",
      "<user>#{@mf_username}</user>",
      "<password>#{@mf_password}</password>",
    )
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