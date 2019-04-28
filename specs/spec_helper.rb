# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative 'test_load_all'


def wipe_database
  # must be in this order to satisfy foreign key constraints
  app.DB[:notes].delete
  app.DB[:projects].delete
  app.DB[:sqlite_sequence].update(seq: 0)
end

DATA = {} # rubocop:disable Style/MutableConstant
DATA[:projects] = YAML.safe_load File.read('specs/seeds/project_seeds.yml')
DATA[:notes] = YAML.safe_load File.read('specs/seeds/note_seeds.yml')
