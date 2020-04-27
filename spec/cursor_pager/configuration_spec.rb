# frozen_string_literal: true

RSpec.describe CursorPager::Configuration do
  after { CursorPager.reset }

  context "when no encoder is specified" do
    it "defaults to Base64Encoder" do
      expect(CursorPager.configuration.encoder)
        .to eq(CursorPager::Base64Encoder)
    end
  end

  context "when a custom encoder is specified" do
    it "uses the custom encoder" do
      encoder = Class.new

      CursorPager.configure { |config| config.encoder = encoder }

      expect(CursorPager.configuration.encoder).to eq(encoder)
    end
  end

  context "when no default_page_size is specified" do
    it "defaults to nil" do
      expect(CursorPager.configuration.default_page_size).to be_nil
    end
  end

  context "when a default_page_size is specified" do
    it "uses the custom default_page_size" do
      CursorPager.configuration.default_page_size = 25

      expect(CursorPager.configuration.default_page_size).to eq(25)
    end
  end

  context "when no maximum_page_size is specified" do
    it "defaults to nil" do
      expect(CursorPager.configuration.maximum_page_size).to be_nil
    end
  end

  context "when a maximum_page_size is specified" do
    it "uses the custom maximum_page_size" do
      CursorPager.configuration.maximum_page_size = 25

      expect(CursorPager.configuration.maximum_page_size).to eq(25)
    end
  end
end
