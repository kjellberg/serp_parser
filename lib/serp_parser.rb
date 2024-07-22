require_relative "serp_parser/version"

require "zeitwerk"
require "public_suffix"
require "nokogiri"
require "date"

loader = Zeitwerk::Loader.for_gem
loader.setup
loader.eager_load

module SerpParser
end
