class CreateStockFinancialConditions < ActiveRecord::Migration[5.2]
  def change
    create_table :stock_financial_conditions do |t|
      t.references :stock_domain, foreign_key: true
      t.integer :market_capitalization
      t.integer :buy_unit
      t.boolean :is_nikkei_average_group
      t.integer :total_asset
      t.integer :shareholder_equity
      t.integer :common_share
      t.integer :retained_earnings

      t.timestamps
    end
  end
end
