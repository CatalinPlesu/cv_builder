class TemplatePdf < ApplicationRecord
  belongs_to :user
  belongs_to :template, touch: true
  has_one_attached :pdf_file

  validates :status, presence: true, inclusion: { in: %w[pending processing completed failed] }

  scope :pending, -> { where(status: "pending") }
  scope :processing, -> { where(status: "processing") }
  scope :completed, -> { where(status: "completed") }
  scope :failed, -> { where(status: "failed") }

  def duration
    return nil unless started_at && completed_at
    completed_at - started_at
  end

  def pending?
    status == "pending"
  end

  def processing?
    status == "processing"
  end

  def completed?
    status == "completed"
  end

  def failed?
    status == "failed"
  end

  def pdf_available?
    completed? && pdf_file.attached?
  end

  def pdf_filename
    base_name = "CV #{user.cv_heading&.full_name} #{template.name}"
    "#{base_name}.pdf"
  end

  def pdf_size
    return nil unless pdf_file.attached?
    pdf_file.blob.byte_size
  end

  def pdf_size_human
    return nil unless pdf_available?
    ActiveSupport::NumberHelper.number_to_human_size(pdf_size)
  end

  # Queue position methods
  def queue_position
    return nil unless pending?

    TemplatePdf.where(status: "pending")
               .where("created_at < ?", created_at)
               .count + 1
  end

  def estimated_wait_time
    return nil unless pending?

    position = queue_position
    return 0 if position <= 1

    # Estimate based on recent completed jobs
    recent_completed = TemplatePdf.completed
                                  .where("completed_at > ?", 1.day.ago)

    if recent_completed.any?
      avg_duration = recent_completed.average("EXTRACT(EPOCH FROM (completed_at - started_at))")
      # Add some buffer time (20% extra)
      estimated_seconds = (position - 1) * avg_duration * 1.2
    else
      # Default estimate: 30 seconds per job if no historical data
      estimated_seconds = (position - 1) * 30
    end

    estimated_seconds.to_i
  end

  def estimated_wait_time_human
    wait_time = estimated_wait_time
    return nil unless wait_time

    if wait_time < 60
      "#{wait_time} seconds"
    elsif wait_time < 3600
      "#{(wait_time / 60).round} minutes"
    else
      "#{(wait_time / 3600).round(1)} hours"
    end
  end

  # Class methods for queue stats
  def self.queue_stats
    {
      total_pending: pending.count,
      total_processing: processing.count,
      total_completed_today: completed.where("completed_at > ?", 1.day.ago).count,
      total_failed_today: failed.where("updated_at > ?", 1.day.ago).count,
      current_processing: processing.first
    }
  end

  def self.average_processing_time
    recent_completed = completed.where("completed_at > ?", 1.week.ago)
                                .where.not(duration: nil)

    return 30 unless recent_completed.any? # Default 30 seconds

    recent_completed.average("EXTRACT(EPOCH FROM (completed_at - started_at))").to_i
  end
end
