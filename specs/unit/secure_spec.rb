# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test SecureDB and SecureMessage' do
  describe 'Test SecureDB' do
    it 'SECURITY: can encrypt and decrypt' do
      plaintext = 'very secret info'
      encrypted = SecureDB.encrypt(plaintext)
      decrypted = SecureDB.decrypt(encrypted)

      _(plaintext).wont_equal encrypted
      _(plaintext).must_equal decrypted
    end
  end
  describe 'Test SecureMessage' do
    it 'SECURITY: can encrypt and decrypt' do
      message = %w[hello there]
      encrypted = SecureMessage.encrypt(message)
      decrypted = SecureMessage.decrypt(encrypted)

      _(encrypted).must_be_kind_of String
      _(message.sort).must_equal decrypted.sort
    end
  end
end
