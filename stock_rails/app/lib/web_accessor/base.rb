module WebAccessor
  class Base
    private

    def access(pre_access_params: {}, post_access_params: {}, &process)
      begin
        @accessor = gen_accessor
        pre_access(@accessor, pre_access_params)
        yield(@accessor)
        post_access(@accessor, post_access_params)
      rescue => e
        screenshot_path = Rails.root.join("tmp", "error_crawl_#{Time.now.strftime("%Y%m%d%H%M%S")}.png")
        @accessor.save_screenshot(screenshot_path)
        Rails.logger.error("スクレイピングエラー発生。#{screenshot_path}にスクリーンショットを保存しました。")
        raise e
      ensure
        @accessor.quit if need_close?
      end
    end

    def gen_accessor
      options = Selenium::WebDriver::Chrome::Options.new
      options.headless! if headless?
      client = Selenium::WebDriver::Remote::Http::Default.new
      client.open_timeout = 240
      client.read_timeout = 240
      Selenium::WebDriver.for(:chrome, options: options, :http_client => client)
    end

    def headless?
      read_env_bool_value("IS_WEB_ACCESS_HEADLESS")
    end

    def need_close?
      read_env_bool_value("REQUIRE_CLOSE_BROWSER")
    end

    def read_env_bool_value(env_key)
      ENV[env_key].to_s.downcase == "true"
    end

    def pre_access(accessor, args) end

    def post_access(accessor, args) end

    def visit(url)
      @accessor.get(url)
      Rails.logger.info("WebAccess: #{url}")
      sleep(1)
    end

    def get_content(target_element: nil, by: :xpath, selector: nil, &parser)
      target = target_element || @accessor
      element = target.find_element(by, selector)
      text = element.text
      if block_given?
        yield(text)
      else
        text
      end
    end
  end
end