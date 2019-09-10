class CreateStockFavorites < ActiveRecord::Migration[5.2]
  def change
    create_table :stock_favorites do |t|
      t.references :stock, foreign_key: true

      t.timestamps
    end
  end
end
