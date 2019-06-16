require 'zip'

module Vitae
  class RenderAndDownloadZip
    def initialize(config)
      @config = config
    end

    def combine(file_id:, extra_files: {}, template: Plasmati)
      sheet = Vitae::Sheet.first(file_id: file_id)
      Zip::OutputStream.write_buffer do |zip|
        dir = "#{@config.ENGINE_DIR}/#{template.dir}"
        Dir.glob("#{dir}/*").each do |fname|
          zip.put_next_entry File.basename(fname)
          File.open(fname, 'r') do |handle|
            handle.each_line do |line|
              zip.print line
            end
          end
        end
        extra_files.each do |name, url|
          URI.open(url) do |f|
            zip.put_next_entry name
            zip.print f.read
          rescue StandardError => e
            puts e
          end
        end
        zip.put_next_entry "#{sheet.name}.tex"
        zip.print GSheet2Latex.new(config: @config, file_id: file_id).render(template: template)
      end
    end
  end
end
