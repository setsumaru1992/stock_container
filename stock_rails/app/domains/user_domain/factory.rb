module UserDomain::Factory
  class << self
    def build_by_api_key(key)
      api_key = ::ApiKey.find_by(key: key)
      raise "Invalid api key." if api_key.nil?
      api_key.user
    end
  end
end