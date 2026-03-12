class FixStuckRunningChecks < ActiveRecord::Migration[7.2]
  def up
    execute <<~SQL
      UPDATE repository_checks
      SET aasm_state = 'failed', passed = false
      WHERE aasm_state = 'running'
    SQL
  end

  def down; end
end
