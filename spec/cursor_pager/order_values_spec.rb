# frozen_string_literal: true

RSpec.describe CursorPager::OrderValues do
  describe ".from_relation" do
    it "returns an empty collection when the order wasn't specified" do
      relation = User.all
      result = described_class.from_relation(relation)

      expect(result.size).to eq(0)
    end

    context "when relation ordering specified as string" do
      it "initializes the order values with that string" do
        relation = User.order("id ASC, created_at ASC")

        expect(CursorPager::OrderValue)
          .to receive(:from_order_string)
          .with(relation, "id ASC, created_at ASC")
          .and_call_original

        result = described_class.from_relation(relation)

        expect(result.size).to eq(2)
      end
    end

    context "when relation ordering specified as hash" do
      it "initializes the order values with the corresponding arel nodes" do
        relation = User.order(id: :asc)

        expect(CursorPager::OrderValue)
          .to receive(:from_arel_node)
          .with(relation, kind_of(Arel::Nodes::Ascending))
          .and_call_original

        result = described_class.from_relation(relation)

        expect(result.size).to eq(1)
      end
    end

    describe "#direction" do
      it "returns the direction of it's first item" do
        relation = User.order(id: :desc)
        order_values = described_class.from_relation(relation)

        expect(order_values.direction).to eq(:desc)
      end
    end

    describe "#order_string" do
      it "joins the order strings of the whole collection" do
        relation = User.order(created_at: :desc, id: :desc)
        order_values = described_class.from_relation(relation)

        expect(order_values.order_string)
          .to eq("users.created_at desc, users.id desc")
      end
    end
  end
end
