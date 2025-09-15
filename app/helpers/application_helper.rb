module ApplicationHelper
  include DateRangeFormatter

  def escape_latex(text)
    text.gsub(/([\\&%$#_{}])/, '\\\\\1')
  end
end
