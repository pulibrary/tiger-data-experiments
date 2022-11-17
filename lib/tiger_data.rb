# frozen_string_literal: true

require "nokogiri"
require "pry-byebug"
require "thor"

require(File.join(__dir__, "..", "nokogiri", "mediaflux"))

module TigerData
  autoload(:Node, File.join(__dir__, "tiger_data", "node"))
  autoload(:List, File.join(__dir__, "tiger_data", "list"))
  autoload(:Cli, File.join(__dir__, "tiger_data", "cli"))

  # This is needed in order to ensure that the Thor runner is loaded
  Cli
end
