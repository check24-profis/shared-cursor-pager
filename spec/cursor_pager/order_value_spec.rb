# frozen_string_literal: true

RSpec.describe CursorPager::OrderValue do
  describe ".from_arel_node" do
    it "initializes an order value" do
      relation = User.order(id: :asc)
      arel_node = relation.order_values.first

      order_value = described_class.from_arel_node(relation, arel_node)

      expect(order_value.attribute).to eq("id")
      expect(order_value.direction).to eq(:asc)
    end
  end

  describe ".from_order_string" do
    it "returns a collection of order values" do
      order_string = "id ASC"
      relation = User.order(order_string)

      result = described_class.from_order_string(relation, order_string)

      expect(result).to all(be_a(described_class))
      expect(result.size).to eq(1)
    end

    it "splits the ordering string" do
      order_string = "id ASC, created_at"
      relation = User.order(order_string)

      result = described_class.from_order_string(relation, order_string)

      expect(result).to all(be_a(described_class))
      expect(result.size).to eq(2)
    end

    it "defaults the direction to asc when it's not specified" do
      order_string = "id"
      relation = User.order(order_string)

      result = described_class.from_order_string(relation, order_string)

      expect(result.first.direction).to eq(:asc)
    end

    it "it raises an exception when it includes a function" do
      order_string = Arel.sql("COALESCE(published_at, created_at) ASC")
      relation = User.order(order_string)

      expect { described_class.from_order_string(relation, order_string) }
        .to raise_error(CursorPager::OrderValueError)
    end
  end

  describe "#primary_key?" do
    it "returns true when the attribute is the relation's primary key" do
      order_value = described_class.new(User.none, "id")

      expect(order_value.primary_key?).to be(true)
    end

    it "returns false when the attribute isn't the relation's primary key" do
      order_value = described_class.new(User.none, "created_at")

      expect(order_value.primary_key?).to be(false)
    end
  end

  describe "#type" do
    it "returns the type of the attribute" do
      relation = User.none
      integer_order_value = described_class.new(relation, "id")
      datetime_order_value = described_class.new(relation, "created_at")

      expect(integer_order_value.type).to eq(:integer)
      expect(datetime_order_value.type).to eq(:datetime)
    end
  end

  describe "#prefixed_attribute" do
    it "prefixes the attribute with the table name" do
      order_value = described_class.new(User.none, "created_at")

      expect(order_value.prefixed_attribute).to eq("users.created_at")
    end

    it "does not prefix already prefixed attributes" do
      order_value = described_class.new(User.none, "users.created_at")

      expect(order_value.prefixed_attribute).to eq("users.created_at")
    end
  end

  describe "#select_alias" do
    it "returns a select alias for the prefixed attribute" do
      order_value = described_class.new(User.none, "created_at")

      expect(order_value.select_alias).to eq("users_created_at")
    end
  end

  describe "#select_string" do
    it "builds a select string for the attribute with an alias" do
      order_value = described_class.new(User.none, "created_at")

      result = order_value.select_string

      expect(result).to eq("users.created_at AS users_created_at")
    end
  end

  describe "#order_string" do
    it "builts an order string" do
      order_value = described_class.new(User.none, "created_at")

      expect(order_value.order_string).to eq("users.created_at asc")
    end
  end
end
