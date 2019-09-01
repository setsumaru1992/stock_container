class CreateStockMeanPrices < ActiveRecord::Migration[5.2]
  def change
    create_table :stock_mean_prices do |t|
      t.references :stock, foreign_key: true
      t.date :day
      t.integer :mean_1week
      t.integer :mean_5week
      t.integer :mean_3month
      t.integer :mean_6month
      t.boolean :has_day_golden_cross
      t.boolean :has_day_dead_cross
      t.boolean :has_week_golden_cross
      t.boolean :has_week_dead_cross

      t.timestamps
    end
  end
end
