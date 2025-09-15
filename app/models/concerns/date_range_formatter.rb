# app/models/concerns/date_range_formatter.rb
module DateRangeFormatter
  extend ActiveSupport::Concern

  def format_date_range(start_date, end_date)
    return "Invalid dates" if start_date && !start_date.is_a?(Date) && !start_date.is_a?(Time)
    return "Invalid dates" if end_date && !end_date.is_a?(Date) && !end_date.is_a?(Time)

    # Handle nil cases
    return "" if start_date.nil? && end_date.nil?

    # Only end date provided
    if start_date.nil? && end_date.present?
      return end_date.strftime("%b %Y")
    end

    # Only start date provided (ongoing)
    if start_date.present? && end_date.nil?
      return "#{start_date.strftime("%b %Y")} – Present"
    end

    # Both dates present
    start_str = start_date.strftime("%b %Y")
    end_str = end_date.strftime("%b %Y")

    # Same month/year
    if start_date.month == end_date.month && start_date.year == end_date.year
      return start_str
    end

    # Same year
    if start_date.year == end_date.year
      return "#{start_date.strftime("%b")} – #{end_date.strftime("%b %Y")}"
    end

    # Different years
    "#{start_str} – #{end_str}"
  end
end
