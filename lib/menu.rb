# frozen_string_literal: true

require 'tty-prompt'

PROMPT = TTY::Prompt.new(prefix: "\n·  ")

def menu_auto_select(question, choices, **opts)
  if choices.empty?
    _menu_no_choices(question, opts)
  elsif choices.size == 1
    _menu_one_choice(question, choices)
  else
    _menu_many_choices(question, choices, opts)
  end
end

def _menu_no_choices(question, opts)
  PROMPT.say("#{question} ")
  PROMPT.error('No choices!')
  opts[:exit_on_error] ? exit(1) : nil
end

def _menu_one_choice(question, choices)
  PROMPT.say("#{question} ")
  if choices.first.is_a?(Hash)
    choice_name = choices.first[:name]
    choice_value = choices.first[:value]
  else
    choice_name = choices.first
    choice_value = choices.first
  end

  PROMPT.ok(choice_name)
  choice_value
end

def _menu_many_choices(question, choices, opts)
  PROMPT.select(question, choices, opts)
end
