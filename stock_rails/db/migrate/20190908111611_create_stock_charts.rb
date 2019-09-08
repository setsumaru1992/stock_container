class CreateStockCharts < ActiveRecord::Migration[5.2]
  def change
    create_table :stock_charts do |t|
      t.references :stock
      t.date :day
      t.integer :range_type
      t.string :image

      t.timestamps
    end
  end
end
