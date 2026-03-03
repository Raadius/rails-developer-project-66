# frozen_string_literal: true

class JsLinterStub
  def self.run(_path)
    { 'summary' => { 'offense_count' => 0 }, 'files' => [] }
  end
end