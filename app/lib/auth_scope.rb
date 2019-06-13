# frozen_string_literal: true

# Scopes for AuthTokens
class AuthScope
  ALL = '*'
  READ = 'read'
  WRITE = 'write'
  EVERYTHING = '*:write' # write includes read
  READ_ONLY = '*:read'
  READ_WRITE = '*:write'
  NOTHING = ':'

  SEPARATOR = ' '
  DIVIDER = ':'

  def initialize(scopes = NOTHING)
    @scopes_str = scopes
    @scopes = {}
    scopes.split(SEPARATOR).map { |scope| add_scope(scope) }
  end

  def can_read?(resource)
    readable?(ALL) || readable?(resource)
  end

  def can_write?(resource)
    writeable?(ALL) || writeable?(resource)
  end

  def to_s
    @scopes_str
  end

  private

  def readable?(resource)
    writeable?(resource) || permission_granted?(resource, READ)
  end

  def writeable?(resource)
    permission_granted?(resource, WRITE)
  end

  def permission_granted?(resource, permission)
    @scopes[resource]&.include?(permission) ? true : false
  end

  def add_scope(scope)
    resource, permission = scope.split(DIVIDER)
    @scopes[resource] ||= []
    @scopes[resource] << permission
  end
end
