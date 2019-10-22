class CreateIndexPrices < ActiveRecord::Migration[5.2]
  def change
    create_table :index_prices do |t|
      t.integer :code
      t.date :day
      t.integer :price

      t.timestamps
    end
  end
end
