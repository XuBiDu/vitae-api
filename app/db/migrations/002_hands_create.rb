# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:hands) do
      primary_key :id
      foreign_key :game_id, table: :games

      String :cards

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
