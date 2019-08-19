class CreateStockConditions < ActiveRecord::Migration[5.2]
  def change
    create_table :stock_conditions do |t|
      t.references :stock_domain, foreign_key: true
      t.text :feature
      t.text :trend
      t.text :current_strategy
      t.integer :category_rank
      t.string :big_stock_holder

      t.timestamps
    end
  end
end
