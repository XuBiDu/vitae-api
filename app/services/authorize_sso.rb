# frozen_string_literal: true

require 'http'

module Vitae
  # Find or create an SsoAccount based on Github code
  class AuthorizeSso
    def initialize(config)
      @config = config
    end

    def call(tokens)
      # google_account = get_google_account(tokens[:id_token])
      google_userinfo = get_google_userinfo(tokens[:access_token])
      raise unless google_userinfo['email_verified']

      google_account = GoogleAccount.new(google_userinfo)
      sso_account = find_or_create_sso_account(google_account)

      account_and_token(sso_account)
    end

    def get_google_account(id_token)
      google_response =
        HTTP.post(@config.GOOGLE_ACCOUNT_ENDPOINT,
                  form: {id_token: id_token})

      raise unless google_response.status == 200

      google_response.parse
    end

    def get_google_userinfo(access_token)
      google_response =
        HTTP.auth("Bearer #{access_token}")
            .get(@config.GOOGLE_USERINFO_ENDPOINT)

      raise unless google_response.status == 200

      google_response.parse
    end

    def find_or_create_sso_account(account_data)
      acc = Account.first(email: account_data.email)
      if acc
        acc.update(name: account_data.name, picture: account_data.picture)
      else
        acc = Account.create_google_account(account_data)
      end
      acc
    end

    def account_and_token(account)
      {
        type: 'sso_account',
        attributes: {
          account: account,
          auth_token: AuthToken.create(payload: account,
                                       scope: AuthScope::EVERYTHING)
        }
      }
    end

    # Maps Google account details to attributes
    class GoogleAccount
      def initialize(google_account)
        @google_account = google_account
      end

      def email
        @google_account['email']
      end

      def username
        @google_account['email']
      end

      def name
        @google_account['name']
      end

      def picture
        @google_account['picture']
      end
    end
  end
end
