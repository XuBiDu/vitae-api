# frozen_string_literal: true

require 'roda'
require_relative './app'

module Vitae
  # Web controller for Credence API
  class Api < Roda
    route('auth') do |r|
      r.on 'register' do
        # POST api/v1/auth/register
        r.post do
          reg_data = JsonRequestBody.parse_symbolize(request.body.read)
          VerifyRegistration.new(Api.config, reg_data).call

          response.status = 202
          { message: 'Verification email sent' }.to_json
        rescue VerifyRegistration::InvalidRegistration => e
          r.halt 400, { message: e.message }.to_json
        rescue StandardError => e
          puts "ERROR VERIFYING REGISTRATION: #{e.inspect}"
          r.halt 500
        end
      end

      r.is 'authenticate' do
        # POST /api/v1/auth/authenticate
        r.post do
          credentials = JsonRequestBody.parse_symbolize(request.body.read)
          auth_account = AuthenticateAccount.call(credentials)
          auth_account.to_json
        rescue AuthenticateAccount::UnauthorizedError => e
          puts [e.class, e.message].join ': '
          r.halt '403', { message: 'Invalid credentials' }.to_json
        end
      end

      r.post 'sso' do
        tokens = JsonRequestBody.parse_symbolize(request.body.read)

        auth_account =
          AuthorizeSso.new(Api.config)
                      .call(tokens)
        { data: auth_account }.to_json
      rescue StandardError => error
        puts "FAILED to validate Google account: #{error.inspect}"
        puts error.backtrace
        r.halt 400
      end
    end
  end
end
