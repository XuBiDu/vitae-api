# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:hands) do
      uuid :id, primary_key: true
      foreign_key :game_id, table: :games

      String :cards_secure

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
