# frozen_string_literal: true

require_relative './app'

module Vitae
  # Web controller for Vitae API
  class Api < Roda
    plugin :all_verbs

    route('download') do |r|
      r.get do
        puts r.inspect

        file_token = r.GET['file_token']
        file_id = SecureMessage.decrypt(file_token)
        template = r.GET['template']

        if template == 'plasmati'
          template_class = Plasmati
        elsif template == 'taraborelli'
          template_class = Taraborelli
        else
          throw 'Unknown template'
        end

        destination = r.GET['destination']
        if destination == 'overleaf'
          engine = template_class.engine
          zip_url = Api.config.ZIP_URL
          snip_uri = CGI.escape("#{zip_url}/download?file_token=#{file_token}&template=#{template}")
          r.redirect "https://www.overleaf.com/docs?engine=#{engine}&snip_uri=#{snip_uri}"
        end

        sheet = Vitae::Sheet.first(file_id: file_id)

        response['Content-Type'] = 'application/zip'
        response['Content-Disposition'] = "attachment; filename=\"#{sheet.name}.zip\""

        RenderAndDownloadZip.new(Api.config)
                            .combine(file_id: file_id,
                                     template: template_class,
                                     extra_files: { 'photo.jpg' => sheet.owner.picture }).string
      # rescue StandardError => e
      #   puts e
      #   r.halt 500
      end
    end
  end
end
