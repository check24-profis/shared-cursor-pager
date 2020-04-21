# frozen_string_literal: true

ActiveRecord::Schema.define do
  self.verbose = false

  create_table :users, force: :cascade do |t|
    t.string :name
    t.datetime :published_at

    t.timestamps
  end

  create_table :books, force: :cascade do |t|
    t.string :name
    t.integer :user_id

    t.timestamps
  end
end
