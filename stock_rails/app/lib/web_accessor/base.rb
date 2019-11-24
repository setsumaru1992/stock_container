module WebAccessor
  class Base
    private

    # ブラウザアクセスしてスクレイピングを行う
    #
    # 注意
    # - 引数のブロック内で冪等性を担保する、つまり何度行なっても同じ結果になる、2度同じプロセスを踏んだときに1度目の値があるからと言って悪さをするような実装にしてはいけない
    #   - 理由：retry時にretry前の値が残っていると結果がおかしくなるため。
    #   - 対策
    #     - ブロック外の値を使わない
    #     - ブロック外の値を使うとしても、ブロック内で"="で丸々置き換えて、そのブロックで独立した値を使えるようにする
    #       - ブロック内の値をメソッドの返り値として返却するためにブロック外で変数定義する場合
    def access(pre_access_params: {}, post_access_params: {}, &process)
      max_retry_count = 5
      retry_count = 0
      begin
        @accessor ||= gen_accessor
        pre_access(@accessor, pre_access_params)
        yield(@accessor)
        post_access(@accessor, post_access_params)
      rescue => e
        if retry_count < max_retry_count
          Rails.logger.warn(e)
          retry_count += 1
          Rails.logger.warn("リトライ #{retry_count}/#{max_retry_count}")
          sleep 120
          retry
        else
          screenshot_path = Rails.root.join("tmp", "error_crawl_#{Time.now.strftime("%Y%m%d%H%M%S")}.png")
          @accessor.save_screenshot(screenshot_path) if @accessor.present?
          Rails.logger.error("スクレイピングエラー発生。#{screenshot_path}にスクリーンショットを保存しました。")
          raise e
        end
      ensure
        @accessor.quit if need_close?
      end
    end

    def gen_accessor
      options = Selenium::WebDriver::Chrome::Options.new
      if headless?
        options.headless!
        options.add_argument("--no-sandbox")
      end
      client = Selenium::WebDriver::Remote::Http::Default.new
      client.open_timeout = 300
      client.read_timeout = 300
      Selenium::WebDriver.for(:chrome, options: options, :http_client => client)
    end

    def headless?
      read_env_bool_value("IS_WEB_ACCESS_HEADLESS")
    end

    def need_close?
      return false if @accessor.nil?
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

    def click_js_trigger(target_element: nil, by: :xpath, selector: nil, wait_target_by: :tag_name, wait_target_selector: "body")
      target = target_element || @accessor
      element = target.find_element(by, selector)
      element.click
      sleep(1)
      ::Selenium::WebDriver::Wait.new(timeout: 300).until do
        @accessor.find_element(wait_target_by, wait_target_selector).displayed?
      end
    end
  end
end
