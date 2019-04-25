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

  it 'HAPPY: should be able to get list of all hands' do
    game = CheatChat::Game.first
    DATA[:hands].each do |hand|
      game.add_hand(hand)
    end

    get "api/v1/games/#{game.id}/hands"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal 2
  end

  it 'HAPPY: should be able to get details of a single hand' do
    hand_data = DATA[:hands][1]
    game = CheatChat::Game.first
    hand = game.add_hand(hand_data).save

    get "/api/v1/games/#{game.id}/hands/#{hand.id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data']['attributes']['id']).must_equal hand.id
    _(result['data']['attributes']['cards']).must_equal hand_data['cards']
  end

  it 'SAD: should return error if unknown hand requested' do
    game = CheatChat::Game.first
    get "/api/v1/games/#{game.id}/hands/foobar"

    _(last_response.status).must_equal 404
  end

  describe 'Creating Hands' do
    before do
      @game = CheatChat::Game.first
      @hand_data = DATA[:hands][1]
      @req_header = { 'CONTENT_TYPE' => 'application/json' }
    end

    it 'HAPPY: should be able to create new hands' do
      post "api/v1/games/#{@game.id}/hands",
           @hand_data.to_json, @req_header
      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['data']['attributes']
      hand = CheatChat::Hand.first

      _(created['id']).must_equal hand.id
      _(created['cards']).must_equal @hand_data['cards']
    end

    it 'SECURITY: should not create hands with mass assignment' do
      bad_hand = @hand_data.clone
      bad_hand['created_at'] = '1900-01-01'
      post "api/v1/games/#{@game.id}/hands",
           bad_hand.to_json, @req_header

      _(last_response.status).must_equal 400
      _(last_response.header['Location']).must_be_nil
    end
  end
end
