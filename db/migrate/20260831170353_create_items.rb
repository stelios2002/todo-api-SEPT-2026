class CreateItems < ActiveRecord::Migration[8.1]
  def change
    create_table :items do |t|
      t.references :todo, null: false, foreign_key: true
      t.string :content, null: false
      t.boolean :completed, default: false, null: false
      t.integer :position

      t.timestamps
    end
  end
end
