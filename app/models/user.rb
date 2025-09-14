class User < ApplicationRecord
  has_one :cv_heading, dependent: :destroy
  has_many :tags, dependent: :destroy
  has_many :templates, dependent: :destroy
  default_scope { includes(:templates) }
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
