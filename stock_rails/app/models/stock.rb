class Stock < ApplicationRecord
  has_many :stock_conditions
  has_many :stock_financial_conditions
  has_many :stock_performances
  has_many :stock_prices
end