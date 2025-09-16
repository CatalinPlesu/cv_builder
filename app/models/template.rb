class Template < ApplicationRecord
  belongs_to :user
  has_and_belongs_to_many :tags
  has_and_belongs_to_many :sections
  has_one :template_pdf, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: :user_id }, length: { maximum: 100 }

  def pdf_generating?
    template_pdf&.pending? || template_pdf&.processing?
  end

  def pdf_failed?
    template_pdf&.failed?
  end

  def build_template_pdf(attributes = {})
    create_template_pdf(attributes)
  end
end
