# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Password Digestion' do
  it 'SECURITY: create password digests safely, hiding raw password' do
    password = 'thereisachancethatthispasswordwillwork'
    digest = Vitae::Password.digest(password)

    _(digest.to_s.match?(password)).must_equal false
  end

  it 'SECURITY: successfully checks correct password from stored digest' do
    password = 'thereisachancethatthispasswordwillwork'
    digest_s = Vitae::Password.digest(password).to_s

    digest = Vitae::Password.from_digest(digest_s)
    _(digest.correct?(password)).must_equal true
  end

  it 'SECURITY: successfully detects incorrect password from stored digest' do
    password1 = 'thereisachancethatthispasswordwillwork'
    password2 = 'tobeornottobe'
    digest_s1 = Vitae::Password.digest(password1).to_s

    digest1 = Vitae::Password.from_digest(digest_s1)
    _(digest1.correct?(password2)).must_equal false
  end
end
