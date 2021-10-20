# frozen_string_literal: true

require 'tty-box'

module Turbulence
  # Interface to and tweaks on top of TTY:Box
  module MessageBox
    module_function

    def warning(message)
      colour_scheme = { fg: :white, bg: :red }
      style = colour_scheme.merge({ border: colour_scheme })

      print "\n", TTY::Box.warn(message, style: style)
    end
  end
end
