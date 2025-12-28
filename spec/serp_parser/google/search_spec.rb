# frozen_string_literal: true

require "spec_helper"

RSpec.describe SerpParser::Google::Search do
  # Find all 2025-*.html files in spec/files/google/
  serp_files = Dir.glob("spec/files/google/2025-*.html").sort

  serp_files.each do |html_file|
    describe "parsing #{File.basename(html_file)}" do
      let(:html) { File.read(html_file) }
      let(:parser) { described_class.new(html) }

      describe "#initialize" do
        it "initializes without error" do
          expect { parser }.not_to raise_error
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

        it "returns the expected number of organic results" do
          expected_size = File.basename(html_file) == "2025-12-23-mobile-best-running-shoes.html" ? 7 : 10
          expect(parser.organic_results.size).to eq(expected_size)
        end

        describe "#position" do
          it "returns position of first organic result" do
            expect(parser.organic_results.first.position).to eq(1)
          end

          it "returns sequential positions" do
            parser.organic_results.each_with_index do |result, index|
              expect(result.position).to eq(index + 1)
            end
          end
        end

        describe "result structure" do
          it "has title, url, and description" do
            parser.organic_results.each do |result|
              expect(result.title).to be_a(String)
              expect(result.url).to be_a(String)
              expect(result.description).to be_a(String).or be_nil
            end
          end
        end
      end
    end
  end
end
