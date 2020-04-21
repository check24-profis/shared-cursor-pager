# frozen_string_literal: true

RSpec.describe CursorPager::LimitRelation do
  describe "#call" do
    it "doesn't change the relation if first & last are nil" do
      2.times { User.create }
      relation = User.order(:id)

      limited_relation = described_class.new(relation, nil, nil).call

      expect(limited_relation).to eq(relation)
    end

    context "when first is not null" do
      it "is applied when there was no previous limit on the relation" do
        users = 5.times.map { User.create }
        relation = User.order(:id)

        limited_relation = described_class.new(relation, 2, nil).call

        expect(limited_relation).to eq(users.first(2))
      end

      it "is applied when it's stricter than the previous limit" do
        users = 5.times.map { User.create }
        relation = User.order(:id).limit(2)

        limited_relation = described_class.new(relation, 1, nil).call

        expect(limited_relation).to eq(users.first(1))
      end

      it "is not applied when the previous limit is stricter" do
        5.times { User.create }
        relation = User.order(:id).limit(1)

        limited_relation = described_class.new(relation, 2, nil).call

        expect(limited_relation).to eq(relation)
      end
    end

    context "when last is not null" do
      it "is applied when there was no previous limit on the relation" do
        users = 5.times.map { User.create }
        relation = User.order(:id)

        limited_relation = described_class.new(relation, nil, 2).call

        expect(limited_relation).to eq(users.last(2))
      end

      it "is applied when it's stricter than the previous limit" do
        users = 5.times.map { User.create }
        relation = User.order(:id).limit(2)

        limited_relation = described_class.new(relation, nil, 1).call

        expect(limited_relation).to eq(users.first(2).last(1))
      end

      it "is not applied when the previous limit is stricter" do
        5.times { User.create }
        relation = User.order(:id).limit(2)

        limited_relation = described_class.new(relation, nil, 3).call

        expect(limited_relation).to eq(relation)
      end
    end

    context "when first and last are not null" do
      it "does not apply last when first is stricter" do
        5.times { User.create }
        relation = User.order(:id)

        limited_relation = described_class.new(relation, 2, 3).call

        expect(limited_relation).to eq(relation.first(2))
      end

      it "applies last when it's stricter than first" do
        5.times { User.create }
        relation = User.order(:id)

        limited_relation = described_class.new(relation, 4, 3).call

        expect(limited_relation).to eq(relation.first(4).last(3))
      end
    end
  end
end
