# frozen_string_literal: true

RSpec.describe CursorPager::SliceRelation do
  describe "#call" do
    it "doesn't change the relation if before & after are nil" do
      2.times { User.create }
      relation = User.order(:id)
      order_values = CursorPager::OrderValue.new(relation, "id")

      sliced_relation = described_class
        .new(relation, order_values, nil, nil).call

      expect(sliced_relation).to eq(relation)
    end

    it "doesn't change the relation if before & after are empty" do
      2.times { User.create }
      relation = User.order(:id)
      order_values = CursorPager::OrderValue.new(relation, "id")

      sliced_relation = described_class.new(relation, order_values, [], []).call

      expect(sliced_relation).to eq(relation)
    end
  end

  # TODO: Move more tests over
end
