# frozen_string_literal: true

RSpec.describe CursorPager::Page do
  describe "#first" do
    it "returns the specified value if it doesn't need to be modified" do
      page = described_class.new(User.none, first: 25)

      expect(page.first).to eq(25)
    end

    it "returns `0` if a negative value was used" do
      page = described_class.new(User.none, first: -25)

      expect(page.first).to eq(0)
    end

    it "returns the `maximum_page_size` if it's smaller then the given value" do
      CursorPager.configuration.maximum_page_size = 10
      page = described_class.new(User.none, first: 25)

      expect(page.first).to eq(10)

      CursorPager.reset
    end

    context "when `first` and `last` were not provided" do
      it "returns nil if no default or maximum were configured" do
        page = described_class.new(User.none, first: nil, last: nil)

        expect(page.first).to eq(nil)
      end

      it "returns the configured default" do
        CursorPager.configuration.default_page_size = 10
        page = described_class.new(User.none, first: nil, last: nil)

        expect(page.first).to eq(10)

        CursorPager.reset
      end

      it "returs the configured maximum when no default was configured" do
        CursorPager.configuration.maximum_page_size = 100
        page = described_class.new(User.none, first: nil, last: nil)

        expect(page.first).to eq(100)

        CursorPager.reset
      end
    end
  end

  describe "#last" do
    it "returns the specified value if it doesn't need to be modified" do
      page = described_class.new(User.none, last: 25)

      expect(page.last).to eq(25)
    end

    it "returns nil if `nil` was used" do
      page = described_class.new(User.none, last: nil)

      expect(page.first).to eq(nil)
    end

    it "returns `0` if a negative value was used" do
      page = described_class.new(User.none, last: -25)

      expect(page.last).to eq(0)
    end

    it "returns the `maximum_page_size` if it's smaller then the given value" do
      CursorPager.configuration.maximum_page_size = 10
      page = described_class.new(User.none, last: 25)

      expect(page.last).to eq(10)

      CursorPager.reset
    end
  end

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

    it "returns true when given a `after` cursor and "\
      "relation includes other relation" do
      books = 2.times.map { Book.create }
      page = described_class.new(
        Book.includes(:user).all, after: encode_cursor(books.first)
      )

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

      it "doesn't crash when a custom select is given" do
        page = described_class.new(User.select("*"), first: 2)
        3.times { User.create }

        expect(page.next_page?).to be(true)
      end
    end

    it "returns true when given a `before` cursor" do
      users = 2.times.map { User.create }
      page = described_class.new(User.all, before: encode_cursor(users.last))

      expect(page.next_page?).to be(true)
    end

    it "returns true when given a `before` cursor and "\
      "relation includes other relation" do
      books = 2.times.map { Book.create }
      page = described_class.new(
        Book.includes(:user).all, before: encode_cursor(books.last)
      )

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
