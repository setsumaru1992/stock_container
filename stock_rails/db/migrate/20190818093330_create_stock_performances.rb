class CreateStockPerformances < ActiveRecord::Migration[5.2]
  def change
    create_table :stock_performances do |t|
      t.references :stock_domain, foreign_key: true
      t.integer :year
      t.integer :month
      t.integer :net_sales
      t.integer :operating_income
      t.integer :ordinary_income
      t.integer :net_income

      t.timestamps
    end
  end
end
