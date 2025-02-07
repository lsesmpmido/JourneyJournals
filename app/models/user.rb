# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  validates :user_name, presence: true, uniqueness: true
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :journals, dependent: :destroy
  has_many :images, through: :journals
  has_many :comments, dependent: :destroy
  has_one_attached :icon

  def name_or_email
    user_name.empty? ? email : user_name
  end
end
