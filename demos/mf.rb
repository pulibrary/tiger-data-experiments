require "./mfclient.rb"
require "byebug"

host = ENV["MF_HOST"]
domain = ENV["MF_DOMAIN"]
user = ENV["MF_USER"]
password = ENV["MF_PASSWORD"]

action = ARGV[0] || "help"
mf = MediaFluxClient.new(host, domain, user, password)

case
when action == "mf-version"
  puts "MediaFlux version"
  puts mf.version()
when action == "create"
  namespace = ARGV[1]
  filename = ARGV[2]
  puts "Create new empty asset #{filename} in namespace #{namespace}"
  puts mf.create(namespace, filename)
when action == "get-metadata"
  id = ARGV[1]
  puts "Metadata for asset id #{id}"
  puts mf.get_metadata(id)
when action == "get-content"
  id = ARGV[1]
  puts mf.get_content(id)
when action == "set-note"
  id = ARGV[1]
  note = ARGV[2]
  puts "Changing note for asset id #{id}"
  puts mf.set_note(id, note)
when action == "query"
  aql_query = ARGV[1]
  puts "Assets for query #{aql_query}"
  puts mf.query(aql_query)
when action == "upload"
  namespace = ARGV[1]
  filename = ARGV[2]
  puts "Uploads file #{filename} to namespace #{namespace}"
  puts mf.upload(namespace, filename)
else
  puts "MediaFlux demo in Ruby"
  puts ""
  puts "Syntax:"
  puts "\tmf action [id]"
  puts ""
  puts "Parameters:"
  puts "\tmf-version - prints MediaFlux version information"
  puts "\tcreate namespace filename - creates an empty file in the namespace indicated"
  puts "\tget id - gets metadata for the asset id indicated"
  puts "\tquery aql_where - queries for assets with the AQL-where clause indicated"
  puts "\tset-note id note - sets a new note for the asset id"
  puts "\tupload namespace filename - uploads file to the namespace indicated"
  puts ""
  puts "Examples:"
  puts "\tcreate /acme my-empty-file.txt"
  puts "\tget-metadata 123456"
  puts "\tget-content 123456 > download.txt"
  puts "\tquery \"namespace='/acme'\""
  puts "\tquery \"namespace='/acme' and ctime>='now-24hour'\""
  puts "\tset-note 12345 \"hello world\""
  puts "\tupload /acme file1.txt"
  puts ""
end

mf.logout()


