class UpdateRepositoryChecksSchema < ActiveRecord::Migration[7.2]
  def change
    rename_column :repository_checks, :status, :aasm_state
    add_column :repository_checks, :passed, :boolean
  end
end
