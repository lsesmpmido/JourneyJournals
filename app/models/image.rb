# frozen_string_literal: true

class Image < ApplicationRecord
  validates :image_name, presence: true

  belongs_to :journal
  has_one_attached :file
  validates :file, presence: true
end
