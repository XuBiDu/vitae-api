# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Hand Handling' do # rubocop:disable Metrics/BlockLength
  include Rack::Test::Methods

  before do
    wipe_database

    DATA[:games].each do |game_data|
      CheatChat::Game.create(game_data)
    end
  end

  it 'HAPPY: should retrieve correct data from database' do
    hand_data = DATA[:hands][1]
    game = CheatChat::Game.first
    new_hand = game.add_hand(hand_data)

    hand = CheatChat::Hand.find(id: new_hand.id)
    _(hand.cards).must_equal new_hand.cards
  end

  it 'SECURITY: should not use deterministic integers' do
    hand_data = DATA[:hands][1]
    game = CheatChat::Game.first
    new_hand = game.add_hand(hand_data)

    _(new_hand.id).wont_be_instance_of Integer
    _(proc { new_hand.id - new_hand.id }).must_raise NoMethodError
  end

  it 'SECURITY: should secure sensitive attributes' do
    hand_data = DATA[:hands][1]
    game = CheatChat::Game.first
    new_hand = game.add_hand(hand_data)
    stored_hand = app.DB[:hands].first

    _(stored_hand[:cards_secure]).wont_equal new_hand.cards
  end
end
