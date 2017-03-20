class CreateSchools < ActiveRecord::Migration[5.0]
  def change
    create_table :schools do |t|
      t.string :name
      t.integer :state_id
      t.string :location
      t.integer :pr_id
      t.string :pr_code

      t.timestamps
    end
  end
end
