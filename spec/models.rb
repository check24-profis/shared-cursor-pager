# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end

class User < ApplicationRecord
  has_many :books
end

class Book < ApplicationRecord
  belongs_to :user
end
