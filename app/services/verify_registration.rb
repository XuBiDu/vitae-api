# frozen_string_literal: true

require 'http'

module Vitae
  # Send email verfification email
  class VerifyRegistration
    # Error for invalid registration details
    class InvalidRegistration < StandardError; end

    SENDGRID_URL = 'https://api.sendgrid.com/v3/mail/send'

    def initialize(config, registration)
      @config = config
      @registration = registration
    end

    def call
      raise(InvalidRegistration, 'Username already exists') unless username_available?
      raise(InvalidRegistration, 'Email already used') unless email_available?

      send_email_verification
    end

    def username_available?
      Account.first(username: @registration[:username]).nil?
    end

    def email_available?
      Account.first(email: @registration[:email]).nil?
    end

    def email_body
      verification_url = @registration[:verification_url]

      <<~END_EMAIL
      <body>
      <html>
      <strong>Vitae² Registration</strong>
      <br>Please <a href=\"#{verification_url}\">click here</a> to verify your
      email.
      <br>You will be asked to set a password to activate your account.</p>
      </body>
      </html>
      END_EMAIL
    end

    # rubocop:disable Metrics/MethodLength
    def send_email_verification
      HTTP.auth(
        "Bearer #{@config.SENDGRID_API_KEY}"
      ).post(
        SENDGRID_URL,
        json: {
          personalizations: [{
            to: [{ 'email' => @registration[:email] }]
          }],
          from: { 'email' => 'vitae2app@gmail.com' },
          subject: 'Vitae² Registration Verification',
          content: [
            { type: 'text/html',
              value: email_body }
          ]
        }
      )
    rescue StandardError => e
      puts "EMAIL ERROR: #{e.inspect}"
      raise(InvalidRegistration,
            'Could not send verification email; please double-check your email address')
    end
    # rubocop:enable Metrics/MethodLength
  end
end
