# frozen_string_literal: true

class Image < ApplicationRecord
  validates :image_name, presence: true

  belongs_to :journal
  has_one_attached :file
  has_one_attached :memo_image
  validates :file, presence: true
  has_many :comments, as: :commentable, dependent: :destroy
end
