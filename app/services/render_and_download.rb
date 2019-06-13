require 'zip'

module Vitae
  class RenderAndDownloadZip
    def initialize(config)
      @config = config
    end

    def combine(file_id: nil, title:, engine: Taraborelli)
      Zip::OutputStream.write_buffer do |zip|
        dir = "#{@config.ENGINE_DIR}/#{engine.dir}"
        Dir.glob("#{dir}/*").each do |fname|
          zip.put_next_entry File.basename(fname)
          File.open(fname, 'r') do |handle|
            handle.each_line do |line|
              zip.print line
            end
          end
        end
        zip.put_next_entry "#{title}.tex"
        zip.print GSheet2Latex.new(config: @config, file_id: file_id).render(engine: engine)
      end
    end
  end
end
