# frozen_string_literal: true

require 'roda'
require 'json'
require_relative './helpers.rb'

module Vitae
  # Web controller for Vitae API
  class Api < Roda
    plugin :halt
    plugin :multi_route
    plugin :all_verbs
    plugin :request_headers
    include SecureRequestHelpers

    route do |r|
      response['Content-Type'] = 'application/json'
      secure_request?(r) ||
        r.halt(403, { message: 'TLS/SSL Required' }.to_json)

      begin
        @auth = authorization(r.headers)
        @auth_account = @auth[:account] if @auth
      rescue AuthToken::InvalidTokenError
        r.halt 403, { message: 'Invalid Auth Token' }.to_json
      end

      r.root do
        { message: 'VitaeAPI is up at /api/v1' }.to_json
      end

      r.on 'api' do
        r.on 'v1' do
          @api_root = 'api/v1'
          r.multi_route
        end
      end
    end
  end
end
