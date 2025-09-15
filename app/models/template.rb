class Template < ApplicationRecord
  belongs_to :user
  has_and_belongs_to_many :tags
  has_and_belongs_to_many :sections

  validates :name, presence: true, uniqueness: { scope: :user_id }, length: { maximum: 100 }
end
