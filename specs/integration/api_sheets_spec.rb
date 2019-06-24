# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test sheet Handling' do
  include Rack::Test::Methods
  VcrHelper.setup_vcr

  before do
    VcrHelper.configure_vcr_for_google
    wipe_database

    @account_data = DATA[:accounts][0]
    @wrong_account_data = DATA[:accounts][1]

    @account = Vitae::Account.create(@account_data)
    @wrong_account = Vitae::Account.create(@wrong_account_data)

    header 'CONTENT_TYPE', 'application/json'
  end

  after do
    VcrHelper.eject_vcr
  end

  describe 'Getting sheets' do
    describe 'Getting list of sheets' do
      before do
        Vitae::CreateSheet.call(auth: authorization(@account_data),
                                title: DATA[:sheets][0]['title'])
        Vitae::CreateSheet.call(auth: authorization(@account_data),
                                title: DATA[:sheets][1]['title'])
      end

      it 'HAPPY: should get list for authorized account' do
        header 'AUTHORIZATION', auth_header(@account_data)
        get 'api/v1/sheets'
        _(last_response.status).must_equal 200

        result = JSON.parse last_response.body
        _(result['data'].count).must_equal 2
      end

      it 'BAD AUTHORIZATION: should not process without authorization' do
        get 'api/v1/sheets'
        _(last_response.status).must_equal 403

        result = JSON.parse last_response.body
        _(result['data']).must_be_nil
      end
    end

    it 'HAPPY: should be able to get details of a single sheet' do
      sheet = Vitae::CreateSheet.call(auth: authorization(@account_data),
                                      title: DATA[:sheets][0]['title'])

      header 'AUTHORIZATION', auth_header(@account_data)
      get "/api/v1/sheet/#{sheet.file_id}"
      _(last_response.status).must_equal 200

      result = JSON.parse(last_response.body)['data']
      _(result['attributes']['id']).must_equal sheet.id
      _(result['attributes']['file_id']).must_equal sheet.file_id
      _(result['attributes']['title']).must_equal sheet.title
    end

    it 'SAD: should return error if unknown sheet requested' do
      header 'AUTHORIZATION', auth_header(@account_data)
      get '/api/v1/sheet/foobar'

      _(last_response.status).must_equal 404
    end

    it 'BAD AUTHORIZATION: should not get sheet with wrong authorization' do
      sheet = Vitae::CreateSheet.call(auth: authorization(@account_data),
                                      title: DATA[:sheets][0]['title'])

      header 'AUTHORIZATION', auth_header(@wrong_account_data)
      get "/api/v1/sheet/#{sheet.file_id}"
      _(last_response.status).must_equal 403

      result = JSON.parse last_response.body
      _(result['attributes']).must_be_nil
    end

    it 'BAD SQL_INJECTION: should prevent basic SQL injection of file_id' do
      Vitae::CreateSheet.call(auth: authorization(@account_data),
                              title: DATA[:sheets][0]['title'])
      Vitae::CreateSheet.call(auth: authorization(@account_data),
                              title: DATA[:sheets][1]['title'])

      header 'AUTHORIZATION', auth_header(@account_data)
      delete 'api/v1/sheet/2%20or%20id%3E0'

      # deliberately not reporting detection -- don't give attacker information
      _(last_response.status).must_equal 404
      _(last_response.body['data']).must_be_nil
    end
  end

  describe 'Creating New Sheets' do
    before do
      @sheet_data = DATA[:sheets][0]
    end

    it 'HAPPY: should be able to create new sheets' do
      header 'AUTHORIZATION', auth_header(@account_data)
      post 'api/v1/sheets', @sheet_data.to_json

      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['attributes']
      sheet = Vitae::Sheet.first

      _(created['id']).must_equal sheet.id
      _(created['title']).must_equal @sheet_data['title']
    end

    it 'SAD AUTHORIZATION: should not create sheet without authorization' do
      post 'api/v1/sheets', @sheet_data.to_json

      created = JSON.parse(last_response.body)['data']

      _(last_response.status).must_equal 403
      _(last_response.header['Location']).must_be_nil
      _(created).must_be_nil
    end

    it 'BAD MASS_ASSIGNMENT: should not create sheet with mass assignment' do
      bad_data = @sheet_data.clone
      bad_data['created_at'] = '1900-01-01'

      header 'AUTHORIZATION', auth_header(@account_data)
      post 'api/v1/sheets', bad_data.to_json

      _(last_response.status).must_equal 400
      _(last_response.header['Location']).must_be_nil
    end
  end

  describe 'Deleting Sheets' do
    before do
      @sheet_data = DATA[:sheets][0]
    end

    it 'HAPPY: should be able to delete sheets' do
      sheet = Vitae::CreateSheet.call(auth: authorization(@account_data),
                                      title: @sheet_data['title'])

      _(sheet.title).must_equal @sheet_data['title']

      sheet = Vitae::Sheet.first(file_id: sheet.file_id)
      _(sheet.title).must_equal @sheet_data['title']

      header 'AUTHORIZATION', auth_header(@account_data)
      delete "api/v1/sheet/#{sheet.file_id}"
      _(last_response.status).must_equal 200

      sheet = Vitae::Sheet.first(file_id: sheet.file_id)
      _(sheet).must_be_nil
    end

    it 'SAD AUTHORIZATION: should not create sheet without authorization' do
      sheet = Vitae::CreateSheet.call(auth: authorization(@account_data),
                                      title: @sheet_data['title'])

      _(sheet.title).must_equal @sheet_data['title']

      sheet = Vitae::Sheet.first(file_id: sheet.file_id)
      _(sheet.title).must_equal @sheet_data['title']

      delete "api/v1/sheet/#{sheet.file_id}"
      _(last_response.status).must_equal 403

      sheet = Vitae::Sheet.first(file_id: sheet.file_id)
      _(sheet).wont_be_nil
    end

    it 'SAD AUTHORIZATION: should report non-existing sheet' do
      header 'AUTHORIZATION', auth_header(@account_data)
      delete "api/v1/sheet/no-such-sheet"
      _(last_response.status).must_equal 404
    end

    it 'BAD AUTHORIZATION: unauthorized user should not delete sheet' do
      sheet = Vitae::CreateSheet.call(auth: authorization(@account_data),
                                      title: @sheet_data['title'])

      _(sheet.title).must_equal @sheet_data['title']

      sheet = Vitae::Sheet.first(file_id: sheet.file_id)
      _(sheet.title).must_equal @sheet_data['title']

      header 'AUTHORIZATION', auth_header(@wrong_account_data)
      delete "api/v1/sheet/#{sheet.file_id}"
      _(last_response.status).must_equal 403

      sheet = Vitae::Sheet.first(file_id: sheet.file_id)
      _(sheet).wont_be_nil
    end
  end
end