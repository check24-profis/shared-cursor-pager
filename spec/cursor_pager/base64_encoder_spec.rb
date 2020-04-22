# frozen_string_literal: true

RSpec.describe CursorPager::Base64Encoder do
  describe ".encode" do
    it "base64 encodes the data" do
      expect(described_class.encode("1")).to eq("MQ==")
    end
  end

  describe ".decode" do
    it "decodes base64 encoded data" do
      expect(described_class.decode("MQ==")).to eq("1")
    end

    it "raises an InvalidCursorError for not-base64-encoded data" do
      expect { described_class.decode("123123") }
        .to raise_error(CursorPager::InvalidCursorError)
    end
  end
end
