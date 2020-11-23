# frozen_string_literal: true

RSpec.describe CursorPager::Page do
  describe "#records" do
    RSpec.shared_examples "works with first/last/before/after arguments" do
      it "returns the whole collection without any arguments" do
        expect(subject.records).to eq(ordered_collection)
      end

      context "when only given `first`" do
        let(:first) { 2 }

        it "limits the collection by that number" do
          expect(subject.records).to eq(ordered_collection.first(2))
        end
      end

      context "when only given `after`" do
        let(:offset) { 1 }
        let(:after_cursor) { encode_cursor(ordered_collection[offset]) }

        it "returns the whole collection after the cursor" do
          expected = ordered_collection[offset + 1..-1]

          expect(subject.records.pluck(:id)).to eq(expected.map(&:id))
        end
      end

      context "when given an empty `after`" do
        let(:after_cursor) { "" }

        it "returns the whole collection" do
          expect(subject.records).to eq(ordered_collection)
        end
      end

      context "when given `first` and `after`" do
        let(:offset) { 1 }
        let(:first) { 2 }
        let(:after_cursor) { encode_cursor(ordered_collection[offset]) }

        it "returns the limited collection after the cursor" do
          expected = ordered_collection[offset + 1..offset + first]

          expect(subject.records).to eq(expected)
        end
      end

      context "when only given `last`" do
        let(:last) { 2 }

        it "limits the collection by that number from the end" do
          expected = ordered_collection.last(2)

          expect(subject.records).to eq(expected)
        end
      end

      context "when only given `before`" do
        let(:offset) { 3 }
        let(:before_cursor) { encode_cursor(ordered_collection[offset]) }

        it "returns the whole collection before the cursor" do
          expected = ordered_collection.first(offset)

          expect(subject.records).to eq(expected)
        end
      end

      context "when given an empty `before`" do
        let(:before_cursor) { "" }

        it "returns the whole collection" do
          expect(subject.records).to eq(ordered_collection)
        end
      end

      context "when given `last` and `before`" do
        let(:offset) { 3 }
        let(:last) { 2 }
        let(:before_cursor) { encode_cursor(ordered_collection[offset]) }

        it "returns the limited collection before the cursor" do
          expected = ordered_collection.first(offset).last(2)

          expect(subject.records).to eq(expected)
        end
      end

      context "when no item could be found for the given `after`" do
        let(:after_cursor) do
          encode_cursor(double(id: relation.maximum(:id) + 1))
        end

        it "returns the whole collection after the cursor" do
          expect { subject.records }
            .to raise_error(CursorPager::CursorNotFoundError)
        end
      end

      context "when no item could be found for the given `before`" do
        let(:before_cursor) do
          encode_cursor(double(id: relation.maximum(:id) + 1))
        end

        it "returns the whole collection after the cursor" do
          expect { subject.records }
            .to raise_error(CursorPager::CursorNotFoundError)
        end
      end
    end

    def encode_cursor(item)
      described_class.new(User.all).cursor_for(item)
    end

    let(:first) { nil }
    let(:last) { nil }
    let(:after_cursor) { nil }
    let(:before_cursor) { nil }

    subject do
      described_class.new(
        relation,
        first: first,
        last: last,
        after: after_cursor,
        before: before_cursor
      )
    end

    context "it orders by primary key when no was predefined" do
      let!(:user2) { User.create(id: 2) }
      let!(:user3) { User.create(id: 3) }
      let!(:user5) { User.create(id: 5) }
      let!(:user1) { User.create(id: 1) }
      let!(:user4) { User.create(id: 4) }

      let(:relation) { User.all }
      let(:ordered_collection) do
        [user1, user2, user3,
         user4, user5]
      end

      include_examples "works with first/last/before/after arguments"
    end

    context "when ordering by primary key" do
      let!(:user2) { User.create(id: 2) }
      let!(:user3) { User.create(id: 3) }
      let!(:user5) { User.create(id: 5) }
      let!(:user1) { User.create(id: 1) }
      let!(:user4) { User.create(id: 4) }

      context "without explicitly specifying the order" do
        let(:relation) { User.order(:id) }
        let(:ordered_collection) { [user1, user2, user3, user4, user5] }

        include_examples "works with first/last/before/after arguments"
      end

      context "in ascending order" do
        let(:relation) { User.order(id: :asc) }
        let(:ordered_collection) { [user1, user2, user3, user4, user5] }

        include_examples "works with first/last/before/after arguments"
      end

      context "in descending order" do
        let(:relation) { User.order(id: :desc) }
        let(:ordered_collection) { [user5, user4, user3, user2, user1] }

        include_examples "works with first/last/before/after arguments"
      end
    end

    context "when ordering by timestamp" do
      let!(:user1) { User.create(created_at: 5.hours.ago) }
      let!(:user2) { User.create(created_at: 4.hours.ago) }
      let!(:user3) { User.create(created_at: 3.hours.ago) }
      let!(:user4) { User.create(created_at: 2.hours.ago) }
      let!(:user5) { User.create(created_at: 1.hour.ago) }

      context "in ascending order" do
        let(:relation) { User.order(created_at: :asc) }
        let(:ordered_collection) { [user1, user2, user3, user4, user5] }

        include_examples "works with first/last/before/after arguments"
      end

      context "in descending order" do
        let(:relation) { User.order(created_at: :desc) }
        let(:ordered_collection) { [user5, user4, user3, user2, user1] }

        include_examples "works with first/last/before/after arguments"
      end
    end

    context "when ordering by timestamp and additionally by primary key" do
      let(:time1) { 2.hours.ago }
      let(:time2) { 1.hour.ago }
      let!(:user1) { User.create(id: 1, created_at: time1) }
      let!(:user2) { User.create(id: 2, created_at: time2) }
      let!(:user3) { User.create(id: 3, created_at: time1) }
      let!(:user4) { User.create(id: 4, created_at: time2) }
      let!(:user5) { User.create(id: 5, created_at: Time.current) }

      context "in ascending order" do
        let(:relation) { User.order(created_at: :asc, id: :asc) }
        let(:ordered_collection) { [user1, user3, user2, user4, user5] }

        include_examples "works with first/last/before/after arguments"
      end

      context "in descending order" do
        let(:relation) { User.order(created_at: :desc, id: :desc) }
        let(:ordered_collection) { [user5, user4, user2, user3, user1] }

        include_examples "works with first/last/before/after arguments"
      end
    end

    context "when ordered by two attributes in different directions" do
      let(:relation) { User.order(created_at: :asc, id: :desc) }

      it "raises an exception" do
        expect { subject }.to raise_error(CursorPager::ConflictingOrdersError)
      end
    end

    context "it orders by ID secondarily when ordering by a non-datetime or "\
      "primary key value" do
      let!(:user1) { User.create(id: 1, name: "Bob") }
      let!(:user2) { User.create(id: 2, name: "Bob") }
      let!(:user3) { User.create(id: 3, name: "Alice") }
      let!(:user4) { User.create(id: 4, name: "Alice") }
      let!(:user5) { User.create(id: 5, name: "Bob") }

      context "in ascending order" do
        let(:relation) { User.order(name: :asc) }
        let(:ordered_collection) { [user3, user4, user1, user2, user5] }

        include_examples "works with first/last/before/after arguments"
      end

      context "in descending order" do
        let(:relation) { User.order(name: :desc) }
        let(:ordered_collection) { [user5, user2, user1, user4, user3] }

        include_examples "works with first/last/before/after arguments"
      end
    end

    context "when order values are strings" do
      let(:time1) { 2.hours.ago }
      let(:time2) { 1.hour.ago }
      let!(:user1) { User.create(id: 1, created_at: time1) }
      let!(:user2) { User.create(id: 2, created_at: time2) }
      let!(:user3) { User.create(id: 3, created_at: time1) }
      let!(:user4) { User.create(id: 4, created_at: time2) }
      let!(:user5) { User.create(id: 5, created_at: Time.current) }

      context "without explicitly specifying the order" do
        let(:relation) { User.order("id") }
        let(:ordered_collection) { [user1, user2, user3, user4, user5] }

        include_examples "works with first/last/before/after arguments"
      end

      context "in ascending order" do
        let(:relation) { User.order("id ASC") }
        let(:ordered_collection) { [user1, user2, user3, user4, user5] }

        include_examples "works with first/last/before/after arguments"
      end

      context "in descending order" do
        let(:relation) { User.order("id desc") }
        let(:ordered_collection) { [user5, user4, user3, user2, user1] }

        include_examples "works with first/last/before/after arguments"
      end

      context "with multiple values" do
        let(:relation) { User.order("created_at ASC, id ASC") }
        let(:ordered_collection) { [user1, user3, user2, user4, user5] }

        include_examples "works with first/last/before/after arguments"
      end
    end

    context "when ordering a relation including joins" do
      let!(:user1) { User.create(id: 1) }
      let!(:user2) { User.create(id: 2) }
      let!(:user3) { User.create(id: 3) }
      let!(:user4) { User.create(id: 4) }
      let!(:user5) { User.create(id: 5) }
      let(:ordered_collection) { [user1, user2, user3, user4, user5] }

      context "and the order values are keywords" do
        let(:relation) { User.left_outer_joins(:books).order(:id) }

        include_examples "works with first/last/before/after arguments"
      end

      context "and the order values are strings" do
        let(:relation) { User.left_outer_joins(:books).order("id") }

        include_examples "works with first/last/before/after arguments"
      end
    end

    context "when ordering based on an attribute of a joined table" do
      let(:user5) { User.create }
      let(:user2) { User.create }
      let(:user3) { User.create }
      let(:user1) { User.create }
      let(:user4) { User.create }

      before do
        Book.create(user: user1)
        Book.create(user: user5)
        Book.create(user: user2)
        Book.create(user: user4)
        Book.create(user: user3)
      end

      context "in ascending order" do
        let(:relation) { User.joins(:books).order("books.created_at ASC") }
        let(:ordered_collection) { [user1, user5, user2, user4, user3] }

        include_examples "works with first/last/before/after arguments"
      end

      context "in descending order" do
        let(:relation) { User.joins(:books).order("books.created_at DESC") }
        let(:ordered_collection) { [user3, user4, user2, user5, user1] }

        include_examples "works with first/last/before/after arguments"
      end
    end

    context "when some associations are preloaded" do
      context "when no cursor specified" do
        let(:user) { User.create }
        let!(:book) { Book.create(user: user) }

        let(:relation) { Book.preload(:user).all }

        it "it correctly preloads assosiations" do
          expect(subject.records.first.association(:user).loaded?).to eq(true)
        end
      end

      context "when the after cursor is specified" do
        let(:user) { User.create }
        let!(:book1) { Book.create(user: user, id: 1) }
        let!(:book2) { Book.create(user: user, id: 2) }

        let(:after_cursor) { described_class.new(Book.all).cursor_for(book1) }
        let(:relation) { Book.preload(:user).all }

        it "it correctly preloads assosiations" do
          expect(subject.records.first.association(:user).loaded?).to eq(true)
        end
      end

      context "when the before cursor is specified" do
        let(:user) { User.create }
        let!(:book1) { Book.create(user: user, id: 1) }
        let!(:book2) { Book.create(user: user, id: 2) }

        let(:before_cursor) { described_class.new(Book.all).cursor_for(book2) }
        let(:relation) { Book.preload(:user).all }

        it "it correctly preloads assosiations" do
          expect(subject.records.first.association(:user).loaded?).to eq(true)
        end
      end
    end

    context "when some associations are eager loaded" do
      context "when no cursor specified" do
        let(:user) { User.create }
        let!(:book) { Book.create(user: user) }

        let(:relation) { Book.eager_load(:user).all }

        it "it correctly preloads assosiations" do
          expect(subject.records.first.association(:user).loaded?).to eq(true)
        end
      end

      context "when the after cursor is specified" do
        let(:user) { User.create }
        let!(:book1) { Book.create(user: user, id: 1) }
        let!(:book2) { Book.create(user: user, id: 2) }

        let(:after_cursor) { described_class.new(Book.all).cursor_for(book1) }
        let(:relation) { Book.eager_load(:user).all }

        it "it correctly preloads assosiations" do
          expect(subject.records.first.association(:user).loaded?).to eq(true)
        end
      end

      context "when the before cursor is specified" do
        let(:user) { User.create }
        let!(:book1) { Book.create(user: user, id: 1) }
        let!(:book2) { Book.create(user: user, id: 2) }

        let(:before_cursor) { described_class.new(Book.all).cursor_for(book2) }
        let(:relation) { Book.eager_load(:user).all }

        it "it correctly preloads assosiations" do
          expect(subject.records.first.association(:user).loaded?).to eq(true)
        end
      end
    end

    context "when some associations are included" do
      context "when no cursor specified" do
        let(:user) { User.create }
        let!(:book) { Book.create(user: user) }

        let(:relation) { Book.includes(:user).all }

        it "it correctly preloads assosiations" do
          expect(subject.records.first.association(:user).loaded?).to eq(true)
        end
      end

      context "when the after cursor is specified" do
        let(:user) { User.create }
        let!(:book1) { Book.create(user: user, id: 1) }
        let!(:book2) { Book.create(user: user, id: 2) }

        let(:after_cursor) { described_class.new(Book.all).cursor_for(book1) }
        let(:relation) { Book.includes(:user).all }

        it "it correctly preloads assosiations" do
          expect(subject.records.first.association(:user).loaded?).to eq(true)
        end
      end

      context "when the before cursor is specified" do
        let(:user) { User.create }
        let!(:book1) { Book.create(user: user, id: 1) }
        let!(:book2) { Book.create(user: user, id: 2) }

        let(:before_cursor) { described_class.new(Book.all).cursor_for(book2) }
        let(:relation) { Book.includes(:user).all }

        it "it correctly preloads assosiations" do
          expect(subject.records.first.association(:user).loaded?).to eq(true)
        end
      end
    end
  end
end
