# frozen_string_literal: true

RSpec.describe CursorPager do
  it "has a version number" do
    expect(CursorPager::VERSION).not_to be(nil)
  end

  it "can load a record from the DB" do
    User.create

    expect(User.count).to eq(1)
    expect(User.first).not_to be(nil)
  end
end
