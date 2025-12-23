# frozen_string_literal: true

require "spec_helper"
require "json"

RSpec.describe SerpParser::Google::OrganicResults::OrganicResult3 do
  it_behaves_like "matches the expected output", "google/organic_result3/general_result"
end
