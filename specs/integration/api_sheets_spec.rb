# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Sheet Handling' do # rubocop:disable Metrics/BlockLength
  include Rack::Test::Methods

  before do
    wipe_database
  end

  describe 'Getting sheets' do # rubocop:disable Metrics/BlockLength
    it 'HAPPY: should be able to get list of all sheets' do
      Vitae::Sheet.create(DATA[:sheets][0]).save
      Vitae::Sheet.create(DATA[:sheets][1]).save

      get 'api/v1/sheets'
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['data'].count).must_equal 2
    end

    it 'HAPPY: should be able to get details of a single sheet' do
      existing_sheet = DATA[:sheets][1]
      Vitae::Sheet.create(existing_sheet).save
      id = Vitae::Sheet.first.id

      get "/api/v1/sheets/#{id}"
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['data']['attributes']['id']).must_equal id
      _(result['data']['attributes']['name']).must_equal existing_sheet['name']
    end

    it 'SAD: should return error if unknown sheet requested' do
      get '/api/v1/sheets/foobar'

      _(last_response.status).must_equal 404
    end

    it 'SECURITY: should prevent basic SQL injection targeting IDs' do
      Vitae::Sheet.create(name: 'First sheet')
      Vitae::Sheet.create(name: 'Second sheet')
      get 'api/v1/sheets/2%20or%20id%3E0'

      # deliberately not reporting error -- don't give attacker information
      _(last_response.status).must_equal 404
      _(last_response.body['data']).must_be_nil
    end
  end

  describe 'Create new sheets' do
    before do
      @req_header = { 'CONTENT_TYPE' => 'application/json' }
      @sheet_data = DATA[:sheets][1]
    end

    it 'HAPPY: should be able to create new sheets' do
      post 'api/v1/sheets', @sheet_data.to_json, @req_header
      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['data']['attributes']
      sheet = Vitae::Sheet.first

      _(created['id']).must_equal sheet.id
      _(created['name']).must_equal @sheet_data['name']
    end

    it 'SECURITY: should not create sheets with mass assignment' do
      bad_sheet = @sheet_data.clone
      bad_sheet['created_at'] = '1900-01-01'

      post 'api/v1/sheets',
           bad_sheet.to_json, @req_header
      _(last_response.status).must_equal 400
      _(last_response.header['Location']).must_be_nil
    end
  end
end
