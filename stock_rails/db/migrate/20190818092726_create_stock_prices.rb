class CreateStockPrices < ActiveRecord::Migration[5.2]
  def change
    create_table :stock_prices do |t|
      t.references :stock_domain, foreign_key: true
      t.date :day
      t.integer :price

      t.timestamps
    end
  end
end
