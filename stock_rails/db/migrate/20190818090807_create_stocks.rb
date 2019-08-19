class CreateStocks < ActiveRecord::Migration[5.2]
  def change
    create_table :stocks do |t|
      t.integer :code
      t.string :name
      t.string :kana
      t.string :industry_name
      t.integer :settlement_month
      t.integer :established_year
      t.integer :listed_year
      t.integer :listed_month
      t.string :category

      t.timestamps
    end
  end
end
