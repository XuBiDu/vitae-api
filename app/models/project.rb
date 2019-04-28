# frozen_string_literal: true

require 'json'
require 'sequel'

module Vitae
  # Models a project
  class Project < Sequel::Model
    one_to_many :notes
    plugin :association_dependencies, notes: :destroy

    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :name

    # rubocop:disable MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'project',
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