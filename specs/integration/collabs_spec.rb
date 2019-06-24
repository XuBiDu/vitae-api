# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Collaborator Handling' do
  include Rack::Test::Methods
  VcrHelper.setup_vcr

  before do
    VcrHelper.configure_vcr_for_google
    # delete_remote_sheets
    wipe_database

    @account_data = DATA[:accounts][0]
    @another_account_data = DATA[:accounts][1]
    @wrong_account_data = DATA[:accounts][2]

    @account = Vitae::Account.create(@account_data)
    @another_account = Vitae::Account.create(@another_account_data)
    @wrong_account = Vitae::Account.create(@wrong_account_data)

    @sheet = Vitae::CreateSheet.call(auth: authorization(@account_data),
                            title: DATA[:sheets][0]['title'])
    header 'CONTENT_TYPE', 'application/json'
  end

  after do
    VcrHelper.eject_vcr
  end

  describe 'Adding collaborators to a sheet' do
    it 'HAPPY: owner can add a valid collaborator' do
      req_data = { email: @another_account.email }

      header 'AUTHORIZATION', auth_header(@account_data)
      put "api/v1/sheet/#{@sheet.file_id}/collabs", req_data.to_json

      added = JSON.parse(last_response.body)['data']['attributes']

      _(last_response.status).must_equal 200
      _(added['username']).must_equal @another_account.username
    end

    it 'SAD AUTHORIZATION: should not add collaborator without authorization' do
      req_data = { email: @another_account.email }

      put "api/v1/sheet/#{@sheet.id}/collabs", req_data.to_json
      added = JSON.parse(last_response.body)['data']

      _(last_response.status).must_equal 403
      _(added).must_be_nil
    end

    it 'BAD AUTHORIZATION: should not add an invalid collaborator' do
      req_data = { email:'nonexistent_account@gmail.com' }

      header 'AUTHORIZATION', auth_header(@account_data)
      put "api/v1/sheet/#{@sheet.file_id}/collabs", req_data.to_json
      added = JSON.parse(last_response.body)['data']

      _(last_response.status).must_equal 404
      _(added).must_be_nil
    end

    it 'BAD AUTHORIZATION: unauthorized user cannot add not add a collaborator' do
      req_data = { email: @account.email }

      header 'AUTHORIZATION', auth_header(@another_account_data)
      put "api/v1/sheet/#{@sheet.file_id}/collabs", req_data.to_json
      added = JSON.parse(last_response.body)['data']

      _(last_response.status).must_equal 403
      _(added).must_be_nil
    end

    it 'BAD AUTHORIZATION: collaborator should not add another collaborator' do
      # add collaborator
      req_data = { email: @another_account.email }

      header 'AUTHORIZATION', auth_header(@account_data)
      put "api/v1/sheet/#{@sheet.file_id}/collabs", req_data.to_json

      added = JSON.parse(last_response.body)['data']['attributes']

      _(last_response.status).must_equal 200
      _(added['username']).must_equal @another_account.username

      req_data = { email: @wrong_account.email }

      header 'AUTHORIZATION', auth_header(@another_account_data)
      put "api/v1/sheet/#{@sheet.file_id}/collabs", req_data.to_json
      added = JSON.parse(last_response.body)['data']

      _(last_response.status).must_equal 403
      _(added).must_be_nil
    end
  end

  describe 'Removing collaborators from a sheet' do
    it 'HAPPY: should remove with proper authorization' do
      @sheet.add_collaborator(@another_account)
      req_data = { email: @another_account.email }

      header 'AUTHORIZATION', auth_header(@account_data)
      delete "api/v1/sheet/#{@sheet.file_id}/collabs", req_data.to_json

      _(last_response.status).must_equal 200
    end

    it 'SAD AUTHORIZATION: should not remove without authorization' do
      @sheet.add_collaborator(@another_account)
      req_data = { email: @another_account.email }

      delete "api/v1/sheet/#{@sheet.file_id}/collabs", req_data.to_json

      _(last_response.status).must_equal 403
    end

    it 'BAD AUTHORIZATION: should not remove invalid collaborator' do
      req_data = { email: @another_account.email }

      header 'AUTHORIZATION', auth_header(@account_data)
      delete "api/v1/sheet/#{@sheet.file_id}/collabs", req_data.to_json

      _(last_response.status).must_equal 403
    end
  end
end