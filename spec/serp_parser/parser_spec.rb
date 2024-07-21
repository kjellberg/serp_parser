# frozen_string_literal: true

require "spec_helper"

RSpec.describe SerpParser::Parser do
  let(:html) { File.read("spec/files/google/response.html") }
  let(:parser) { described_class.new(html) }

  describe "#initialize" do
    it "initializes without errors" do
      expect { parser }.not_to raise_error
    end
  end
end
