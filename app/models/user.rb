# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  validates :user_name, presence: true, uniqueness: true

  has_many :journals, dependent: :destroy
  has_many :images, through: :journals

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_one_attached :icon
end
