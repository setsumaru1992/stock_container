class DebugController < ApplicationController
  def debug
    message = "hoge"
    render json: {
      result: message
    }
  end

  def google_scrape
    browser = ::Selenium::WebDriver.for(
      :remote, 
      url: "http://stock_selenium_hub:4444/wd/hub", 
      desired_capabilities: :chrome
    )
    content = ""
    begin
      browser.get("https://google.com/")
      save_screenshot(browser)
      content = browser.find_element(:tag_name, "title")
    ensure
      browser.quit # 少なくともこれを入れないとcapacityが足りなくなる。
    end
    render json: {content: content}
  end

  def web_accsessor_scrape
    DebugWebAccessor.new.url_access("https://google.com/")
    render json: {message: "screenshot取得完了"}
  end

  def sbi_scrape
    DebugWebAccessor.new.url_access("https://www.sbisec.co.jp/ETGate/")
    render json: {message: "screenshot取得完了"}
  end

  private

  def save_screenshot(web_driver)
    screenshot_path = Rails.root.join("tmp", "screenshot_crawl_#{Time.now.strftime("%Y%m%d%H%M%S")}.png")
    web_driver.save_screenshot(screenshot_path)
  end

  class DebugWebAccessor < ::WebAccessor::Base
    def url_access(url)
      access do |accessor|
        visit(url)
        
        screenshot_path = Rails.root.join("tmp", "screenshot_crawl_#{Time.now.strftime("%Y%m%d%H%M%S")}.png")
        accessor.save_screenshot(screenshot_path)
      end
    end
  end
end