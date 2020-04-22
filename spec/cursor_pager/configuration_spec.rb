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
end
