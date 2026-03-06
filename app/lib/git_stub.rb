# frozen_string_literal: true

class GitStub
  def self.clone(_url, _path)
    # no-op in tests
  end
end
