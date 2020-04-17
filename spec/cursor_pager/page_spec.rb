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

  describe "#cursor_for" do
    it "returns the cursor for the item" do
      item = User.new(id: 1)
      page = described_class.new(User.all)

      expect(page.cursor_for(item)).to eq("MQ==")
    end
  end

  describe "#records" do
    it "returns all the records of the relation" do
      bob = User.create(name: "Bob")
      alice = User.create(name: "Alice")
      page = described_class.new(User.all)

      expect(page.records).to contain_exactly(bob, alice)
    end
  end
end
