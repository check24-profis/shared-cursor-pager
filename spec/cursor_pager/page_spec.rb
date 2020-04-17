# frozen_string_literal: true

RSpec.describe CursorPager::Page do
  describe "#previous_page?" do
    it "returns false" do
      page = described_class.new(User.all)

      expect(page.previous_page?).to be(false)
    end
  end

  describe "#next_page?" do
    it "returns false" do
      page = described_class.new(User.all)

      expect(page.next_page?).to be(false)
    end
  end
end
