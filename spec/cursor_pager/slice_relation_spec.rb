# frozen_string_literal: true

RSpec.describe CursorPager::SliceRelation do
  describe "#call" do
    it "doesn't change the relation if before & after values are nil" do
      2.times { User.create }
      relation = User.order(:id)

      sliced_relation = slice_relation(relation, nil, nil)

      expect(sliced_relation).to eq(relation)
    end

    it "doesn't change the relation if before & after values are empty" do
      2.times { User.create }
      relation = User.order(:id)

      sliced_relation = slice_relation(relation, [], [])

      expect(sliced_relation).to eq(relation)
    end

    context "when the after values are not empty" do
      context "when ordered by one attribute in ascending direction" do
        it "correctly slices the relation" do
          users = 5.times.map { User.create }
          relation = User.order(:id)
          cursor = [users[2].id]

          sliced_relation = slice_relation(relation, cursor, [])

          expect(sliced_relation).to eq(users[3..-1])
        end
      end

      context "when ordered by one attribute in descending direction" do
        it "correctly slices the relation" do
          users = 5.times.map { User.create }.reverse
          relation = User.order(id: :desc)
          cursor = [users[2].id]

          sliced_relation = slice_relation(relation, cursor, [])

          expect(sliced_relation).to eq(users[3..-1])
        end
      end

      context "when ordered by multiple attributes in ascending direction" do
        it "correctly slices the relation" do
          users = 5.times.map { User.create }
          relation = User.order(id: :asc, created_at: :asc)
          cursor = [users[2].id, users[2].created_at]

          sliced_relation = slice_relation(relation, cursor, [])

          expect(sliced_relation).to eq(users[3..-1])
        end
      end

      context "when ordered by multiple attributes in descending direction" do
        it "correctly slices the relation" do
          users = 5.times.map { User.create }.reverse
          relation = User.order(id: :desc, created_at: :desc)
          cursor = [users[2].id, users[2].created_at]

          sliced_relation = slice_relation(relation, cursor, [])

          expect(sliced_relation).to eq(users[3..-1])
        end
      end
    end

    context "when the before values are not empty" do
      context "when ordered by one attribute in ascending direction" do
        it "correctly slices the relation" do
          users = 5.times.map { User.create }
          relation = User.order(:id)
          cursor = [users[3].id]

          sliced_relation = slice_relation(relation, [], cursor)

          expect(sliced_relation).to eq(users[0..2])
        end
      end

      context "when ordered by one attribute in descending direction" do
        it "correctly slices the relation" do
          users = 5.times.map { User.create }.reverse
          relation = User.order(id: :desc)
          cursor = [users[3].id]

          sliced_relation = slice_relation(relation, [], cursor)

          expect(sliced_relation).to eq(users[0..2])
        end
      end

      context "when ordered by multiple attributes in ascending direction" do
        it "correctly slices the relation" do
          users = 5.times.map { User.create }
          relation = User.order(id: :asc, created_at: :asc)
          cursor = [users[3].id, users[3].created_at]

          sliced_relation = slice_relation(relation, [], cursor)

          expect(sliced_relation).to eq(users[0..2])
        end
      end

      context "when ordered by multiple attributes in descending direction" do
        it "correctly slices the relation" do
          users = 5.times.map { User.create }.reverse
          relation = User.order(id: :desc, created_at: :desc)
          cursor = [users[3].id, users[3].created_at]

          sliced_relation = slice_relation(relation, [], cursor)

          expect(sliced_relation).to eq(users[0..2])
        end
      end
    end
  end

  def slice_relation(relation, after_values, before_values)
    described_class.new(
      relation,
      CursorPager::OrderValues.from_relation(relation),
      after_values,
      before_values
    ).call
  end
end
