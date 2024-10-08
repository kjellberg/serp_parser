# frozen_string_literal: true

require "spec_helper"

RSpec.describe SerpParser::Google::Search do
  let(:html) { File.read("spec/files/google/full_html_response.html") }
  let(:doc) { Nokogiri::HTML::DocumentFragment.parse(html) }
  let(:parser) { described_class.new(html) }
  let(:parser_with_html) { described_class.new(html) }

  describe "#initialize" do
    it "initializes with doc" do
      expect { parser }.not_to raise_error
    end

    it "initializes with html" do
      expect { parser_with_html }.not_to raise_error
    end
  end

  describe "#search_information" do
    it "returns hash with information" do
      expect(parser.search_information).to be_an_instance_of(Hash)
    end
  end

  describe "#organic_results" do
    it "returns a collection object" do
      expect(parser.organic_results).to be_an_instance_of(SerpParser::Collection)
    end

    it "returns organic results" do
      expect(parser.organic_results).to all(be_an_instance_of(SerpParser::Models::OrganicResult))
    end

    it "returns 7 organic results" do
      expect(parser.organic_results.size).to eq(7)
    end

    describe "#site_links of first result" do
      it "returns an array of site links" do
        expect(parser.organic_results.first.site_links).to all(be_an_instance_of(SerpParser::Models::OrganicResults::SiteLink))
      end

      it "returns 4 site links" do
        expect(parser.organic_results.first.site_links.size).to eq(4)
      end
    end

    describe "#position" do
      it "returns position of first organic result" do
        expect(parser.organic_results.first.position).to eq(1)
      end

      it "returns position of last organic result" do
        expect(parser.organic_results.last.position).to eq(7)
      end

      it "returns position of 5th organic result" do
        expect(parser.organic_results[4].position).to eq(5)
      end
    end
  end
end
