# frozen_string_literal: true

require "spec_helper"
require "json"

RSpec.describe SerpParser::Google::OrganicResults::OrganicResult4 do
  it_behaves_like "matches the expected output", "google/organic_result5/general_result"
  it_behaves_like "matches the expected output", "google/organic_result5/with_rating"
end
