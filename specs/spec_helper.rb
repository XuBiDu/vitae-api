# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative 'test_load_all'

def wipe_database # rubocop:disable Metrics/AbcSize
  # must be in this order to satisfy foreign key constraints
  app.DB[:notes].delete
  app.DB[:sheets].delete
  app.DB[:accounts].delete
  app.DB[:sqlite_sequence].update(seq: 0)
end

DATA = {} # rubocop:disable Style/MutableConstant
DATA[:accounts] = YAML.safe_load File.read('app/db/seeds/accounts_seed.yml')
DATA[:sheets] = YAML.safe_load File.read('app/db/seeds/sheets_seed.yml')
DATA[:notes] = YAML.safe_load File.read('app/db/seeds/notes_seed.yml')
