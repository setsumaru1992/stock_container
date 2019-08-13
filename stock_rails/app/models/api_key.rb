class ApiKey < ApplicationRecord
  belongs_to :user

  def gen_key
    str_length = 16
    seeds = (0..9).to_a + ("a".."z").to_a + ("A".."Z").to_a
    @key = seeds.sample(str_length).join
  end
end
