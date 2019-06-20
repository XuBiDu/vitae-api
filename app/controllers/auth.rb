# frozen_string_literal: true

require 'roda'
require_relative './app'

module Vitae
  # Web controller for Vitae API
  class Api < Roda
    route('auth') do |r|

      begin
        @request_data = SignedRequest.new(Api.config).parse(request.body.read)
      rescue SignedRequest::VerificationError
        r.halt '403', { message: 'Must sign request' }.to_json
      end

      puts @request_data.inspect

      r.on 'register' do
        # POST api/v1/auth/register
        r.post do
          VerifyRegistration.new(Api.config, @request_data).call

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
          auth_account = AuthenticateAccount.call(@request_data)
          auth_account.to_json
        rescue AuthenticateAccount::UnauthorizedError => e
          puts [e.class, e.message].join ': '
          r.halt '403', { message: 'Invalid credentials' }.to_json
        end
      end

      r.post 'sso' do
        # tokens = JsonRequestBody.parse_symbolize(request.body.read)

        auth_account =
          AuthorizeSso.new(Api.config)
                      .call(@request_data)
        { data: auth_account }.to_json
      rescue StandardError => error
        puts "FAILED to validate Google account: #{error.inspect}"
        puts error.backtrace
        r.halt 400
      end
    end
  end
end
