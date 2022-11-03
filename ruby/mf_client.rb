require 'net/http'

class MFClient
  def initialize(mf_host:, mf_port:, mf_domain:, mf_username:, mf_password:)
    @mf_host = mf_host
    @mf_port = mf_port
    @mf_domain = mf_domain
    @mf_username = mf_username
    @mf_password = mf_password
  end

  def mf_post(body)
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