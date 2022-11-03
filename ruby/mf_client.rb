require 'net/http'

class MFClient
  def initialize(mf_host:, mf_port:, mf_domain:, mf_username:, mf_password:)
    @mf_host = mf_host
    @mf_port = mf_port
    @mf_domain = mf_domain
    @mf_username = mf_username
    @mf_password = mf_password
  end

  def call(service_name, *xml_args)
    session_attr = @session ? %Q{session="#{@session}"} : ''
    request_xml = %Q{<request>
      <service name="#{service_name}" #{session_attr}>
        <args>#{xml_args.join()}</args>
      </service>
    </request>}
    post(request_xml)
  end

  def session()
    response_doc = self.call("system.logon",
      "<domain>#{@mf_domain}</domain>",
      "<user>#{@mf_username}</user>",
      "<password>#{@mf_password}</password>",
    )
    @session = response_doc.elements["response/reply/result/session"].text
    # Note: "reply/result" are not in the docs

    response_doc = self.call("asset.namespace.list")
    puts response_doc

    response_doc = self.call("system.logoff")
    puts response_doc
  end

  private

  def post(body)
    https = Net::HTTP.new(@mf_host, @mf_port)
    https.use_ssl = true
    https.read_timeout = 3 # I often forget the VPN, so set this low.
    https.continue_timeout = 3
    request = Net::HTTP::Post.new("__mflux_svc__")
    request.body = body
    request["Content-Type"] = "text/xml; charset=utf-8"
    response = https.request(request)
    REXML::Document.new(response.body)
  end
end