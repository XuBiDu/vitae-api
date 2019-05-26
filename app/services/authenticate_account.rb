# frozen_string_literal: true

module Vitae
    # Find account and check password
  class AuthenticateAccount
      # Error for invalid credentials
    class UnauthorizedError < StandardError
      def initialize(msg = nil)
        @credentials = msg
      end

      def message
        "Invalid Credentials for: #{@credentials[:username]}"
      end
    end

    def self.call(credentials)
      begin
        account = Account.first(username: credentials[:username])
        raise(UnauthorizedError, credentials) if !account.password?(credentials[:password])
      rescue StandardError => exception
        raise(UnauthorizedError, credentials)
      end
      account_and_token(account)
    end

    def self.account_and_token(account)
      {
        type: 'authenticated_account',
        attributes: {
          account: account,
          auth_token: AuthToken.create(account)
        }
      }
    end
  end
end