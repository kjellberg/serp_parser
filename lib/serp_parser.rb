require_relative "serp_parser/version"

require "public_suffix"
require "nokogiri"

module SerpParser
  autoload :Parser, "serp_parser/parser"

  module Models
    autoload :OrganicResult, "serp_parser/models/organic_result"
  end

  module Google
    autoload :Search, "serp_parser/google/search"
    module OrganicResults
      autoload :OrganicResult1, "serp_parser/google/organic_results/organic_result1"
    end
  end
end
