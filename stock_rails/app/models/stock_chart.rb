class StockChart < ApplicationRecord
  belongs_to :stock
  mount_uploader :image, StockChartImageUploader

  ONE_DAY = :ONE_DAY
  TWO_DAY = :TWO_DAY
  FIVE_DAY = :FIVE_DAY
  THREE_DAY = :THREE_DAY
  TEN_DAY = :TEN_DAY
  ONE_MONTH = :ONE_MONTH
  TWO_MONTH = :TWO_MONTH
  THREE_MONTH = :THREE_MONTH
  SIX_MONTH = :SIX_MONTH
  ONE_YEAR = :ONE_YEAR
  TWO_YEAR = :TWO_YEAR
  THREE_YEAR = :THREE_YEAR
  FIVE_YEAR = :FIVE_YEAR
  TEN_YEAR = :TEN_YEAR
  TWENTY_YEAR = :TWENTY_YEAR

  RANGE_TYPE_HASH = {
    ONE_DAY: 1,
    TWO_DAY: 2,
    FIVE_DAY: 3,
    TEN_DAY: 4,
    THREE_DAY: 5,
    ONE_MONTH: 6,
    TWO_MONTH: 7,
    THREE_MONTH: 8,
    SIX_MONTH: 9,
    ONE_YEAR: 10,
    TWO_YEAR: 11,
    THREE_YEAR: 12,
    FIVE_YEAR: 13,
    TEN_YEAR: 14,
    TWENTY_YEAR: 15
  }
end
