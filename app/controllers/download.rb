# frozen_string_literal: true

require_relative './app'

module Vitae
  # Web controller for Vitae API
  class Api < Roda
    plugin :all_verbs

    route('download') do |r|
      r.get do
        throw "No file_token" unless file_token = r.GET['file_token']
        throw "No template" unless template = r.GET['template']
        throw "No destination" unless destination = r.GET['destination']

        if template == 'plasmati'
          template_class = Plasmati
        elsif template == 'taraborelli'
          template_class = Taraborelli
        else
          throw 'Unknown template'
        end

        file_id = SecureMessage.decrypt(file_token)
        sheet = Vitae::Sheet.first(file_id: file_id)

        if destination == 'overleaf'
          engine = template_class.engine
          zip_url = Api.config.ZIP_URL
          snip_uri = CGI.escape("#{zip_url}/download?file_token=#{file_token}&template=#{template}")
          url = "https://www.overleaf.com/docs?engine=#{engine}&snip_uri=#{snip_uri}&snip_name=#{sheet.title}"
          r.redirect url
        end

        throw 'Unknown destination' unless destination == 'direct'

        response['Content-Type'] = 'application/zip'
        response['Content-Disposition'] = "attachment; filename=\"#{sheet.title}.zip\""

        extra_files =
          if sheet.owner.picture
            { 'photo.jpg' => sheet.owner.picture }
          else
            {}
          end

        RenderAndDownloadZip.new(Api.config)
                            .combine(file_id: file_id,
                                     template: template_class,
                                     extra_files: extra_files).string
        rescue SecureMessage::BadCiphertextError
          r.halt 403
        rescue StandardError => e
          r.halt 404
      end
    end
  end
end
