# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Project Handling' do # rubocop:disable Metrics/BlockLength
  include Rack::Test::Methods

  before do
    wipe_database
  end

  describe 'Getting projects' do # rubocop:disable Metrics/BlockLength
    it 'HAPPY: should be able to get list of all projects' do
      Vitae::Project.create(DATA[:projects][0]).save
      Vitae::Project.create(DATA[:projects][1]).save

      get 'api/v1/projects'
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['data'].count).must_equal 2
    end

    it 'HAPPY: should be able to get details of a single project' do
      existing_project = DATA[:projects][1]
      Vitae::Project.create(existing_project).save
      id = Vitae::Project.first.id

      get "/api/v1/projects/#{id}"
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['data']['attributes']['id']).must_equal id
      _(result['data']['attributes']['name']).must_equal existing_project['name']
    end

    it 'SAD: should return error if unknown project requested' do
      get '/api/v1/projects/foobar'

      _(last_response.status).must_equal 404
    end

    it 'SECURITY: should prevent basic SQL injection targeting IDs' do
      Vitae::Project.create(name: 'First project')
      Vitae::Project.create(name: 'Second project')
      get 'api/v1/projects/2%20or%20id%3E0'

      # deliberately not reporting error -- don't give attacker information
      _(last_response.status).must_equal 404
      _(last_response.body['data']).must_be_nil
    end
  end

  describe 'Create new projects' do
    before do
      @req_header = { 'CONTENT_TYPE' => 'application/json' }
      @project_data = DATA[:projects][1]
    end

    it 'HAPPY: should be able to create new projects' do
      post 'api/v1/projects', @project_data.to_json, @req_header
      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['data']['attributes']
      project = Vitae::Project.first

      _(created['id']).must_equal project.id
      _(created['name']).must_equal @project_data['name']
    end

    it 'SECURITY: should not create projects with mass assignment' do
      bad_project = @project_data.clone
      bad_project['created_at'] = '1900-01-01'

      post 'api/v1/projects',
           bad_project.to_json, @req_header
      _(last_response.status).must_equal 400
      _(last_response.header['Location']).must_be_nil
    end
  end
end
