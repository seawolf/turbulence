# frozen_string_literal: true

require 'tty-prompt'

PROMPT = TTY::Prompt.new(prefix: "\n·  ")

def menu_auto_select(question, choices, **opts)
  if choices.empty?
    _menu_no_choices(question, opts.merge(auto_select: true))
  else
    _menu_many_choices(question, choices, opts.merge(auto_select: true))
  end
end

def _menu_no_choices(question, opts)
  PROMPT.say("#{question} ")
  PROMPT.error('No choices!')
  opts[:exit_on_error] ? exit(1) : nil
end

def _menu_many_choices(question, choices, opts)
  PROMPT.select(question, choices, opts)
end
