# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative 'test_load_all'


def wipe_database
  # must be in this order to satisfy foreign key constraints
  app.DB[:hands].delete
  app.DB[:games].delete
  app.DB[:sqlite_sequence].update(seq: 0)
end

DATA = {} # rubocop:disable Style/MutableConstant
DATA[:games] = YAML.safe_load File.read('specs/seeds/game_seeds.yml')
DATA[:hands] = YAML.safe_load File.read('specs/seeds/hand_seeds.yml')
