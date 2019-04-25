# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Game Handling' do # rubocop:disable Metrics/BlockLength
  include Rack::Test::Methods

  before do
    wipe_database
  end

  describe 'Getting games' do # rubocop:disable Metrics/BlockLength
    it 'HAPPY: should be able to get list of all games' do
      CheatChat::Game.create(DATA[:games][0]).save
      CheatChat::Game.create(DATA[:games][1]).save

      get 'api/v1/games'
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['data'].count).must_equal 2
    end

    it 'HAPPY: should be able to get details of a single game' do
      existing_game = DATA[:games][1]
      CheatChat::Game.create(existing_game).save
      id = CheatChat::Game.first.id

      get "/api/v1/games/#{id}"
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['data']['attributes']['id']).must_equal id
      _(result['data']['attributes']['name']).must_equal existing_game['name']
    end

    it 'SAD: should return error if unknown game requested' do
      get '/api/v1/games/foobar'

      _(last_response.status).must_equal 404
    end

    it 'SECURITY: should prevent basic SQL injection targeting IDs' do
      CheatChat::Game.create(name: 'First game')
      CheatChat::Game.create(name: 'Second game')
      get 'api/v1/games/2%20or%20id%3E0'

      # deliberately not reporting error -- don't give attacker information
      _(last_response.status).must_equal 404
      _(last_response.body['data']).must_be_nil
    end
  end

  describe 'Create new games' do
    before do
      @req_header = { 'CONTENT_TYPE' => 'application/json' }
      @game_data = DATA[:games][1]
    end

    it 'HAPPY: should be able to create new games' do
      post 'api/v1/games', @game_data.to_json, @req_header
      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['data']['attributes']
      game = CheatChat::Game.first

      _(created['id']).must_equal game.id
      _(created['name']).must_equal @game_data['name']
    end

    it 'SECURITY: should not create games with mass assignment' do
      bad_game = @game_data.clone
      bad_game['created_at'] = '1900-01-01'

      post 'api/v1/games',
           bad_game.to_json, @req_header
      _(last_response.status).must_equal 400
      _(last_response.header['Location']).must_be_nil
    end
  end
end
