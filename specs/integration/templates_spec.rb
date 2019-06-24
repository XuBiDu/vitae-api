# frozen_string_literal: true

require_relative '../spec_helper'

module Templates
  def zip_template(template, sheet)
    zip = Vitae::RenderAndDownloadZip.new(Vitae::Api.config)
      .combine(file_id: sheet.file_id,
              template: template,
              extra_files: {}).string
    _(zip.length).must_be :>, 10_000
    files = []
    Zip::InputStream.open(StringIO.new(zip)) do |io|
      while (entry = io.get_next_entry)
        files.append(entry.to_s)
      end
    end
    _(files.include?("#{DATA[:sheets][0]['title']}.tex")).must_equal true
  end
end

describe 'Test LaTeX Templates' do
  include Rack::Test::Methods

  include Templates
  include Rack::Test::Methods
  VcrHelper.setup_vcr

  before do
    VcrHelper.configure_vcr_for_google

    # delete_remote_sheets
    wipe_database
    @config = Vitae::Api.config
    @account_data = DATA[:accounts][0]
    @account = Vitae::Account.create(@account_data)
    @sheet = Vitae::CreateSheet.call(auth: authorization(@account_data),
                            title: DATA[:sheets][0]['title'])
    header 'CONTENT_TYPE', 'application/json'
  end

  after do
    VcrHelper.eject_vcr
  end

  it 'HAPPY: Taraborelli template cab render' do
    latex = GSheet2Latex.new(config: @config, file_id: @sheet.file_id).render(template: Taraborelli)
    latex.must_include "\\begin{document}"
    latex.must_include "\\end{document}"

    zip_template(Taraborelli, @sheet)
  end

  it 'HAPPY: Plasmati template can render' do
    latex = GSheet2Latex.new(config: @config, file_id: @sheet.file_id).render(template: Plasmati)
    latex.must_include "\\begin{document}"
    latex.must_include "\\end{document}"

    zip_template(Plasmati, @sheet)
  end

  it 'HAPPY: can download latex with file token' do
    file_token = SecureMessage.encrypt(@sheet.file_id)
    template = 'plasmati'
    destination = 'direct'

    get "api/v1/download?file_token=#{file_token}&template=#{template}&destination=#{destination}"
    _(last_response.status).must_equal 200
    _(last_response.body.length).must_be :>, 10_000
  end

  it 'HAPPY: can redirect to overleaf' do
    file_token = SecureMessage.encrypt(@sheet.file_id)
    template = 'plasmati'
    destination = 'overleaf'

    get "api/v1/download?file_token=#{file_token}&template=#{template}&destination=#{destination}"
    _(last_response.status).must_equal 302
    _(last_response.header['Location']).must_include 'overleaf.com'
  end

  it 'SAD: cannot download with wrong parameter' do
    template = 'plasmati'
    destination = 'direct'

    get "api/v1/download?file_id=#{@sheet.file_id}&template=#{template}&destination=#{destination}"
    _(last_response.status).must_equal 404
  end

  it 'SAD: cannot download with wrong parameter' do
    file_token = SecureMessage.encrypt(@sheet.file_id)
    template = 'unknown'
    destination = 'direct'

    get "api/v1/download?file_token=#{file_token}&template=#{template}&destination=#{destination}"
    _(last_response.status).must_equal 404
  end

  it 'BAD: cannot download with file id' do
    file_token = @sheet.file_id
    template = 'plasmati'
    destination = 'direct'

    get "api/v1/download?file_token=#{file_token}&template=#{template}&destination=#{destination}"
    _(last_response.status).must_equal 403
  end

  it 'BAD: cannot redirect to another destination' do
    file_token = SecureMessage.encrypt(@sheet.file_id)
    template = 'plasmati'
    destination = 'other'

    get "api/v1/download?file_token=#{file_token}&template=#{template}&destination=#{destination}"
    _(last_response.status).must_equal 404
  end

end
