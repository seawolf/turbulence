# frozen_string_literal: true

require 'tty-prompt'

module Turbulence
  # Interface to and tweaks on top of TTY:Prompt
  module Menu
    PROMPT = TTY::Prompt.new(prefix: "\n·  ")

    module_function

    def auto_select(question, choices, **opts)
      if choices.empty?
        _no_choices(question, opts.merge(auto_select: true))
      else
        _many_choices(question, choices, opts.merge(auto_select: true, per_page: TTY::Screen.height - 4, filter: true))
      end
    end

    def _no_choices(question, opts)
      PROMPT.say("#{question} ")
      PROMPT.error('No choices!')

      _exit if opts[:exit_on_error]
    end

    def _many_choices(question, choices, opts)
      PROMPT.select(question, choices, opts)
    end

    def _exit
      return RSpec::Turbulence::SystemExit if defined?(RSpec)

      # :nocov:
      exit(1)
      # :nocov:
    end
  end
end
