class CreateLoto7Purchases < ActiveRecord::Migration[7.2]
  def change
    create_table :loto7_purchases do |t|
      t.string :number_set, null: false
      t.integer :price, default: 300, null: false

      t.timestamps
    end
  end
end
