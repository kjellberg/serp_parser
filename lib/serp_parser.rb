require_relative "serp_parser/version"

require "public_suffix"
require "nokogiri"

module SerpParser
  autoload :Parser, "serp_parser/parser"
end
