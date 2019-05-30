# frozen_string_literal: true
require_relative 'google_utils'

gu = GoogleUtils.new
data = gu.sheet_data(file_id: gu.template)
puts data.inspect
