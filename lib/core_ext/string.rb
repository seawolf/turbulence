# frozen_string_literal: true

class String
  def present?
    strip.length.positive?
  end
end
