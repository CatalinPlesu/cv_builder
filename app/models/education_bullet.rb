class EducationBullet < ApplicationRecord
  belongs_to :education

  default_scope { order(position: :asc) }
end
