# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Note Noteling' do # rubocop:disable Metrics/BlockLength
  include Rack::Test::Methods

  before do
    wipe_database

    DATA[:projects].each do |project_data|
      Vitae::Project.create(project_data)
    end
  end

  it 'HAPPY: should retrieve correct data from database' do
    note_data = DATA[:notes][1]
    project = Vitae::Project.first
    new_note = project.add_note(note_data)

    note = Vitae::Note.find(id: new_note.id)
    _(note.text).must_equal new_note.text
  end

  it 'SECURITY: should not use deterministic integers' do
    note_data = DATA[:notes][1]
    project = Vitae::Project.first
    new_note = project.add_note(note_data)

    _(new_note.id).wont_be_instance_of Integer
    _(proc { new_note.id - new_note.id }).must_raise NoMethodError
  end

  it 'SECURITY: should secure sensitive attributes' do
    note_data = DATA[:notes][1]
    project = Vitae::Project.first
    new_note = project.add_note(note_data)
    stored_note = app.DB[:notes].first

    _(stored_note[:text_secure]).wont_equal new_note.text
  end
end
