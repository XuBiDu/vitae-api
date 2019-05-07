# frozen_string_literal: true

require 'json'
require 'sequel'

module Vitae
  # Models a project
  class Project < Sequel::Model
    many_to_one :owner, class: :'Vitae::Account'

    many_to_many :collaborators,
                 class: :'Vitae::Account',
                 join_table: :accounts_projects,
                 left_key: :project_id, right_key: :collaborator_id

    one_to_many :notes
    plugin :association_dependencies,
           notes: :destroy,
           collaborators: :nullify

    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :name, :repo_url

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