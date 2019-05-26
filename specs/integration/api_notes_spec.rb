# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Note Handling' do # rubocop:disable Metrics/BlockLength
  include Rack::Test::Methods

  before do
    wipe_database

    DATA[:sheets].each do |sheet_data|
      Vitae::Sheet.create(sheet_data)
    end
  end

  it 'HAPPY: should be able to get list of all notes' do
    sheet = Vitae::Sheet.first
    DATA[:notes].each do |note|
      sheet.add_note(note)
    end

    get "api/v1/sheets/#{sheet.id}/notes"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal 2
  end

  it 'HAPPY: should be able to get details of a single note' do
    note_data = DATA[:notes][1]
    sheet = Vitae::Sheet.first
    note = sheet.add_note(note_data).save

    get "/api/v1/sheets/#{sheet.id}/notes/#{note.id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data']['attributes']['id']).must_equal note.id
    _(result['data']['attributes']['text']).must_equal note_data['text']
  end

  it 'SAD: should return error if unknown note requested' do
    sheet = Vitae::Sheet.first
    get "/api/v1/sheets/#{sheet.id}/notes/foobar"

    _(last_response.status).must_equal 404
  end

  describe 'Creating Notes' do
    before do
      @sheet = Vitae::Sheet.first
      @note_data = DATA[:notes][1]
      @req_header = { 'CONTENT_TYPE' => 'application/json' }
    end

    it 'HAPPY: should be able to create new notes' do
      post "api/v1/sheets/#{@sheet.id}/notes",
           @note_data.to_json, @req_header
      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['data']['attributes']
      note = Vitae::Note.first

      _(created['id']).must_equal note.id
      _(created['text']).must_equal @note_data['text']
    end

    it 'SECURITY: should not create notes with mass assignment' do
      bad_note = @note_data.clone
      bad_note['created_at'] = '1900-01-01'
      post "api/v1/sheets/#{@sheet.id}/notes",
           bad_note.to_json, @req_header

      _(last_response.status).must_equal 400
      _(last_response.header['Location']).must_be_nil
    end
  end
end
