# frozen_string_literal: true

RSpec.describe CursorPager::Page do
  describe "#previous_page?" do
    context "when given `last`" do
      it "returns true if it is smaller than the available edges" do
        3.times { User.create }
        page = described_class.new(User.all, last: 2)

        expect(page.previous_page?).to be(true)
      end

      it "returns false if it equals or is bigger than the available edges" do
        2.times { User.create }
        page = described_class.new(User.all, last: 2)

        expect(page.previous_page?).to be(false)
      end

      it "does not break if the relation won't get an offset set" do
        3.times { User.create }
        page = described_class.new(User.limit(2), last: 3)

        expect(page.previous_page?).to be(false)
      end
    end

    it "returns true when given an `after` cursor" do
      users = 2.times.map { User.create }
      page = described_class.new(User.all, after: encode_cursor(users.first))

      expect(page.previous_page?).to be(true)
    end

    it "returns false when given no arguments" do
      page = described_class.new(User.all)

      expect(page.previous_page?).to be(false)
    end
  end

  describe "#next_page?" do
    context "when given `first" do
      let(:page) { described_class.new(User.all, first: 2) }

      it "returns true if it is smaller than the available edges" do
        3.times { User.create }

        expect(page.next_page?).to be(true)
      end

      it "returns false if it equals or is bigger than the available edges" do
        2.times { User.create }

        expect(page.next_page?).to be(false)
      end
    end

    it "returns true when given a `before` cursor" do
      users = 2.times.map { User.create }
      page = described_class.new(User.all, before: encode_cursor(users.last))

      expect(page.next_page?).to be(true)
    end

    it "returns false when given no arguments" do
      page = described_class.new(User.all)

      expect(page.next_page?).to be(false)
    end
  end

  describe "#first_cursor" do
    it "returns nil if the page is empty" do
      page = described_class.new(User.none)

      expect(page.first_cursor).to be_nil
    end

    it "returns the cursor of the page's first record" do
      users = 3.times.map { User.create }
      page = described_class.new(User.all)

      expect(page.first_cursor).to eq(page.cursor_for(users.first))
    end
  end

  describe "#last_cursor" do
    it "returns nil if the page is empty" do
      page = described_class.new(User.none)

      expect(page.last_cursor).to be_nil
    end

    it "returns the cursor of the page's first record" do
      users = 3.times.map { User.create }
      page = described_class.new(User.all)

      expect(page.last_cursor).to eq(page.cursor_for(users.last))
    end
  end

  def encode_cursor(item)
    described_class.new(User.all).cursor_for(item)
  end
end
