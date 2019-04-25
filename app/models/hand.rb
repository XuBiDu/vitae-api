# frozen_string_literal: true

require 'json'
require 'sequel'

module CheatChat
  # Models a hand
  class Hand < Sequel::Model
    many_to_one :game

    plugin :uuid, field: :id

    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :cards

    # Secure getters and setters
    def cards
      SecureDB.decrypt(cards_secure)
    end

    def cards=(plaintext)
      self.cards_secure = SecureDB.encrypt(plaintext)
    end

    # rubocop:disable MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'hand',
            attributes: {
              id: id,
              cards: cards
            }
          },
          included: {
            game: game
          }
        }, options
      )
    end
    # rubocop:enable MethodLength
  end
end
