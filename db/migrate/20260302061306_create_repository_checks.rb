class CreateRepositoryChecks < ActiveRecord::Migration[7.2]
  def change
    create_table :repository_checks do |t|
      t.string :commit_id
      t.string :status, null: false, default: 'pending'
      t.integer :issues_count
      t.references :repository, null: false, foreign_key: true

      t.timestamps
    end
  end
end
