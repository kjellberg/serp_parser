# frozen_string_literal: true

require "spec_helper"
require "json"

RSpec.describe SerpParser::Google::OrganicResults::OrganicResult1 do
  it_behaves_like "matches the expected output", "google/organic_result1/general_result"
  it_behaves_like "matches the expected output", "google/organic_result1/with_site_links"
end
