# frozen_string_literal: true

require 'roda'
require 'json'
# require_relative './helpers.rb'

module Vitae
  # Web controller for Vitae Gen
  class Api < Roda

    route('download.zip') do |r|
      r.on String do |file_token|
        r.get do
          puts SecureMessage.decrypt(file_token)
          puts 'hello'
          r.halt 501
          response['Content-Type'] = 'application/zip'
          RenderAndDownloadZip.new(App.config)
                              .combine(file_id: file_id, title: 'hello').string
        rescue StandardError => e
          puts e
          r.halt 500
        end
      end
    end
  end
end
