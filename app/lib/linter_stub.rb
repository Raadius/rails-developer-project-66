# frozen_string_literal: true

class LinterStub
  def self.run(_path, _: nil)
    { 'summary' => { 'offense_count' => 0 }, 'files' => [] }
  end
end
