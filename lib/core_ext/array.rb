# frozen_string_literal: true

class Array
  def present?
    length.positive?
  end

  def presence
    present? ? self : nil
  end
end
