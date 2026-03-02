# frozen_string_literal: true

class GitStub
  class << self
    def clone?(_clone_url, _path)
      true
    end
  end
end
