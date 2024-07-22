require_relative "serp_parser/version"

require "public_suffix"
require "nokogiri"
require "zeitwerk"

loader = Zeitwerk::Loader.for_gem
loader.setup # ready!

module SerpParser
  autoload :Parser, "serp_parser/parser"

  module Models
    autoload :OrganicResult, "serp_parser/models/organic_result"

    module OrganicResults
      autoload :SiteLink, "serp_parser/models/organic_results/site_link"
    end
  end

  module Google
    autoload :Search, "serp_parser/google/search"

    module OrganicResults
      autoload :OrganicResult1, "serp_parser/google/organic_results/organic_result1"

      module SiteLinks
        autoload :SiteLink1, "serp_parser/google/organic_results/site_links/site_link1"
      end
    end
  end
end

loader.eager_load
