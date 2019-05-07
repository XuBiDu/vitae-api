# frozen_string_literal: true

require 'json'
require 'sequel'

module Vitae
  # Models a note
  class Note < Sequel::Model
    many_to_one :project

    plugin :uuid, field: :id

    plugin :timestamps, update_on_create: true
    plugin :whitelist_security
    set_allowed_columns :text

    # Secure getters and setters
    def text
      SecureDB.decrypt(text_secure)
    end

    def text=(plaintext)
      self.text_secure = SecureDB.encrypt(plaintext)
    end

    # rubocop:disable MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'note',
            attributes: {
              id: id,
              text: text
            }
          },
          included: {
            project: project
          }
        }, options
      )
    end
    # rubocop:enable MethodLength
  end
end
