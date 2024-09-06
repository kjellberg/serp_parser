# frozen_string_literal: true

require "spec_helper"

RSpec.describe SerpParser::Google::Search do
  let(:html) { File.read("spec/files/google/2024-09-06-matkasse.html") }
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

    it "returns 98 organic results" do
      expect(parser.organic_results.size).to eq(100)
    end

    it "returns featured post as first organic result" do
      expect(parser.organic_results.first.title).to eq("Linas Matkasse: Goda, hälsosamma matkassar med 30% rabatt!")
      expect(parser.organic_results.first.description).to match("Nystart för hela familjen - med Linas Matkasse. ✓ Färska och lokala råvaror i säsong ✓ 80 sunda, goda recept i veckan ✓ Ingen bindningstid. Beställ matkasse.")
      expect(parser.organic_results.first.url).to eq("https://www.linasmatkasse.se/")
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
        expect(parser.organic_results.last.position).to eq(100)
      end

      it "returns position of 10th organic result" do
        expect(parser.organic_results[9].position).to eq(10)
      end
    end
  end
end
