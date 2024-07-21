# frozen_string_literal: true

require "spec_helper"

RSpec.describe SerpParser::Google::Search do
  let(:html) { File.read("spec/files/google/full_html_response.html") }
  let(:parser) { described_class.new(html) }

  describe "#initialize" do
    it "initializes without errors" do
      expect { parser }.not_to raise_error
    end
  end

  describe "#search_information" do
    it "returns hash with information" do
      expect(parser.search_information).to be_an_instance_of(Hash)
    end
  end

  describe "#organic_results" do
    it "returns an array of organic results" do
      expect(parser.organic_results).to all(be_an_instance_of(SerpParser::Models::OrganicResult))
    end

    it "returns 7 organic results" do
      expect(parser.organic_results.size).to eq(7)
    end
  end

  describe "#data" do
    it "matches with the expected output" do
      expected = {
        organic_results: [],
        search_information: {}
      }
      expect(parser.data).to match(expected)
    end
  end
end
