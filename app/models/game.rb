# frozen_string_literal: true

require 'json'
require 'sequel'

module CheatChat
  # Models a project
  class Game < Sequel::Model
    one_to_many :hands
    plugin :association_dependencies, hands: :destroy

    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :name

    # rubocop:disable MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'game',
            attributes: {
              id: id,
              name: name
            }
          }
        }, options
      )
    end
    # rubocop:enable MethodLength
  end
end