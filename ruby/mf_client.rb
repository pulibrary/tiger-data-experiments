require 'net/http'

class MFClient
  def initialize(mf_host:, mf_port:, mf_domain:, mf_username:, mf_password:)
    @mf_host = mf_host
    @mf_port = mf_port
    @mf_domain = mf_domain
    @mf_username = mf_username
    @mf_password = mf_password
  end

  def call(service_name, *xml_args, session: nil)
    session_attr = session ? %Q{session="#{session}"} : ''
    request_xml = %Q{<request>
      <service name="#{service_name}" #{session_attr}>
        <args>#{xml_args.join()}</args>
      </service>
    </request>}
    post(request_xml)
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