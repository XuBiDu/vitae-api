# frozen_string_literal: true

require 'roda'
require_relative './app'

module Vitae
  # Web controller for Vitae API
  class Api < Roda
    route('accounts') do |r|
      @account_route = "#{@api_root}/accounts"
      r.on String do |username|
        r.halt(403, UNAUTH_MSG) unless @auth_account

        # GET api/v1/accounts/[username]
        r.get do
          auth = AuthorizeAccount.call(
            auth: @auth, username: username,
            auth_scope: AuthScope.new(AuthScope::READ_ONLY)
          )
          { data: auth }.to_json
        rescue AuthorizeAccount::ForbiddenError => e
          r.halt 404, { message: e.message }.to_json
        rescue StandardError => e
          puts "GET ACCOUNT ERROR: #{e.inspect}"
          r.halt 500, { message: 'API Server Error' }.to_json
        end
      end

      # POST api/v1/accounts
      r.post do
        new_data = SignedRequest.new(Api.config).parse(request.body.read)
        new_account = Account.new(new_data)
        raise('Could not save account') unless new_account.save

        response.status = 201
        response['Location'] = "#{@account_route}/#{new_account.username}"
        { message: 'Account saved', data: new_account }.to_json
      rescue Sequel::MassAssignmentRestriction
        r.halt 400, { message: 'Illegal Request' }.to_json
      rescue SignedRequest::VerificationError
        routing.halt 403, { message: 'Must sign request' }.to_json
      rescue StandardError => e
        r.halt 500, { message: e.message }.to_json
      end
    end
  end
end
