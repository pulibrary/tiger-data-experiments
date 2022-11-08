require "net/http"
require "nokogiri"

# A very simple client to interface with a MediaFlux server.
class MediaFluxClient
  def initialize(host, domain, user, password)
    @host = host
    @domain = domain
    @user = user
    @password = password
    @base_url = "http://#{host}:80/__mflux_svc__/"
    @xml_declaration = '<?xml version="1.0" encoding="UTF-8"?>'
    connect()
  end

  # Fetches MediaFlux's server version information (in XML)
  def version
    xml_request = <<-XML_BODY
      <request>
        <service name="server.version" session="#{@session_id}"/>
      </request>
    XML_BODY
    response_body = http_post(xml_request)
  end

  # Terminates the current session
  def logout
    xml_request = <<-XML_BODY
      <request>
        <service name="system.logoff" session="#{@session_id}"/>
      </request>
    XML_BODY
    response_body = http_post(xml_request)
  end

  # Queries for assets on the given namespace
  def query(aql_where)
    xml_request = <<-XML_BODY
      <request>
        <service name="asset.query" session="#{@session_id}">
          <args>
            <where>#{aql_where}</where>
          </args>
        </service>
      </request>
    XML_BODY
    response_body = http_post(xml_request)
  end

  # Fetches metadata for the given asset it
  def get(id)
    xml_request = <<-XML_BODY
      <request>
        <service name="asset.get" session="#{@session_id}" sgen="0" seq="2">
          <args>
            <id>#{id}</id>
          </args>
        </service>
      </request>
    XML_BODY
    response_body = http_post(xml_request)
  end

  def set_note(id, mf_note)
    xml_request = <<-XML_BODY
      <request>
        <service name="asset.set" session="#{@session_id}">
          <args>
            <id>#{id}</id>
            <meta>
              <mf-note>
                <note>#{mf_note}</note>
              </mf-note>
            </meta>
          </args>
        </service>
      </request>
    XML_BODY
    response_body = http_post(xml_request)
  end

  # Creates an empty file (no content) with the name provided
  def create(namespace, filename)
    xml_request = <<-XML_BODY
      <request>
        <service name="asset.create" session="#{@session_id}" data-out-min="0" data-out-max="0">
          <args>
            <name>#{filename}</name>
            <namespace>#{namespace}</namespace>
          </args>
        </service>
      </request>
    XML_BODY
    response_body = http_post(xml_request)
  end

  # Uploads a file to the given namespace
  def upload(namespace, filename_fullpath)
    filename = File.basename(filename_fullpath)
    xml_request = <<-XML_BODY
    <request>
      <service name="asset.create" session="#{@session_id}" sgen="0" seq="2">
        <args>
          <namespace create="True">#{namespace}</namespace>
          <name>#{filename}</name>
          <meta><mf-name><name>#{filename}</name></mf-name></meta>
        </args>
        <attachment></attachment>
      </service>
    </request>
    XML_BODY
    file_content = File.read(filename_fullpath)
    response_body = http_post(xml_request, file_content)
  end

  private
    def http_post(payload, file_content = nil)
      url = @base_url
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      if url.start_with?("https://")
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      request = Net::HTTP::Post.new(url)

      if file_content.nil?
        request["Content-Type"] = "text/xml"
        request.body = @xml_declaration + payload
      else
        # For uploading files we use a different content-type that seems to be specific to MediaFlux.
        request["Content-Type"] = "application/mflux"
        xml = @xml_declaration + payload
        mflux_request = xml_separator(xml) + xml + content_separator(file_content) + file_content
        request.body = mflux_request
      end
      response = http.request(request)
      response.body
    end

    def xml_separator(xml)
      file_format = "text/xml"
      part1 = 1.chr + 0.chr + hex_bytes(xml.length)
      part2 = 0.chr + 0.chr + 0.chr + 1.chr + 0.chr + file_format.length.chr
      part1 + part2 + file_format
    end

    def content_separator(content)
      part1 = 1.chr + 0.chr + hex_bytes(content.length)
      part2 = 0.chr + 0.chr + 0.chr + 1.chr + 0.chr + 0.chr
      part1 + part2
    end

    def hex_bytes(number)
      hex_bytes = []
      # Force the string to be 16 characters long so we can guarantee 8 pairs.
      number_hex = number.to_s(16).rjust(16, "0")
      (0..7).each do |i|
        n = i * 2
        hex = number_hex[n..n+1]
        hex_bytes << hex.to_i(16).chr
      end
      hex_bytes.join()
    end

    def connect()
      xml_request = <<-XML_BODY
        <request>
          <service name="system.logon" sgen="0" seq="1">
            <args>
              <host>#{@host}</host>
              <domain>#{@domain}</domain>
              <user>#{@user}</user>
              <password>#{@password}</password>
            </args>
          </service>
        </request>
      XML_BODY
      response_body = http_post(xml_request)
      xml = Nokogiri::XML(response_body)
      @session_id = xml.xpath("//response/reply/result/session").first.text
    end
end
