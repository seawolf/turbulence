# frozen_string_literal: true

module Turbulence
  module GCloud
    # Item in the menu system
    class Action
      def initialize
        choices = Actions::LIST
                  .map { |action| Action.new(action::ID, action::NAME, action) }
                  .map(&:to_choice)

        action = Menu.auto_select('Select your desired action:', choices, per_page: choices.length)
        Config.set(:action, action.id)

        action.class_name.new
      end

      Action = Struct.new(:id, :name, :class_name) do
        def to_choice
          {
            name: name,
            value: self
          }
        end
      end
    end
  end
end
