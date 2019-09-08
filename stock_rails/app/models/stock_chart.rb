class StockChart < ApplicationRecord
  mount_uploader :image, StockChartImageUploader
end
