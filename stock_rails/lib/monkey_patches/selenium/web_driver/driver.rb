module Selenium::WebDriver
  class Driver
    def find_element(*args)
      super(*args)
    rescue Selenium::WebDriver::Error::NoSuchElementError
      nil
    end

    def find_elements(*args)
      super(*args)
    rescue Selenium::WebDriver::Error::NoSuchElementError
      []
    end
  end
end