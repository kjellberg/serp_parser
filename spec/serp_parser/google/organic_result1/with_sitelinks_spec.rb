# frozen_string_literal: true

require "spec_helper"
require "json"

RSpec.describe SerpParser::Google::OrganicResults::OrganicResult1 do
  let(:html) { File.read("spec/files/google/organic_result1/organic_result1-with_site_links.html") }
  let(:expected_output) { JSON.parse(File.read("spec/files/google/organic_result1/organic_result1-with_site_links.json")) }
  let(:doc) { Nokogiri::HTML::DocumentFragment.parse(html) }
  let(:parser) { described_class.new(html) }
  let(:processed_data) { parser.processed_data }

  describe "#initialize" do
    it "initializes with html" do
      expect { parser }.not_to raise_error
    end
  end

  it "matches the expected output" do
    expect(processed_data.to_h).to match(expected_output)
  end
end
