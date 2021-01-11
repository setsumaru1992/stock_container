module WebAccessor::Sbi
  class Base < ::WebAccessor::Base
    LOGIN_URL = "https://site2.sbisec.co.jp/ETGate/?_ControlID=WPLETlgR001Control&_PageID=WPLETlgR001Rlgn50&_DataStoreID=DSWPLETlgR001Control&_ActionID=login&getFlg=on"

    def initialize(need_credential: false, user_name: nil, password: nil, close_each_access: true)
      super(close_each_access: close_each_access)
      @need_credential = need_credential
      if need_credential
        raise "Initialize needs credential information." if user_name.nil? || password.nil?
        @user_name = user_name
        @password = password
      else
        @user_name = user_name || ENV["SBI_INFO_GETTER_USERNAME"]
        @password = password || ENV["SBI_INFO_GETTER_PASSWORD"]
      end

    end

    private

    # Override
    def pre_access(accessor, args)
      login(accessor)
    end

    def login(accessor)
      visit(LOGIN_URL)

      ::Selenium::WebDriver::Wait.new(timeout: 60 * 30).until do
        accessor.find_element(:name, "user_id").displayed?
      end
      accessor.find_element(:name, "user_id").send_keys(@user_name)
      accessor.find_element(:name, "user_password").send_keys(@password)

      retry_count = 0
      begin
        accessor.find_element(:name, "logon").click
      rescue => e
        raise e if retry_count > 50
        # バナーが自動で消えるのを待つ
        sleep(2)
        retry_count += 1
        retry
      end
    end

    def get_price_chart_image_paths_in_iframe(iframe_xpath, range_keys, image_name, image_dir, image_extension: "jpeg")
      switch_to_iframe(iframe_xpath)
      image_path_and_range_list = range_keys.map do |range_key|
        image_path = get_price_chart_image_path_in_iframe(range_key, image_dir, image_name, image_extension)
        [image_path, range_key]
      end
      image_path_and_range_list
    end

    # TODO: Method::ChartImageCreatableのincludeに移行。すべての使用箇所でこのメソッドを使用しなくなったときこのメソッドを削除
    def get_concated_price_chart_image_path_in_iframe(iframe_xpath, range_keys, image_name, image_dir, image_extension: "jpeg")
      switch_to_iframe(iframe_xpath)
      image_paths = range_keys.map do |range_key|
        get_price_chart_image_path_in_iframe(range_key, image_dir, image_name, image_extension)
      end
      return image_paths.first if image_paths.size == 1
      ImageManager::Base.concate_images(image_paths, unique_path("#{image_dir}/#{image_name}.#{image_extension}"))
    end

    def get_price_chart_image_path_in_iframe(range_key, image_dir, image_name, image_extension)
      tab_idx = ChartRange::RANGE_XPATH_IDX_HASH[range_key]
      click_js_trigger(
        selector: "//*[@id='MAINAREA01']/div/div/div/div/div[1]/ul/li[#{tab_idx}]/a",
        wait_target_by: :xpath,
        wait_target_selector: "//img[@id='chartImg']"
      )

      image_url = @accessor.find_element(:xpath, "//img[@id='chartImg']").attribute("src")
      image_path = unique_path("#{image_dir}/#{image_name}_#{range_key.to_s.downcase}.#{image_extension}")
      download_image_from(image_url, image_path, "gif")
    end

    def download_image_from(url, image_path, download_extension)
      image_extension = ImageManager::Base.extension_of(image_path)
      download_filepath = if download_extension == image_extension
        image_path
      else
        "#{image_path}.#{download_extension}"
      end

      open(download_filepath, "wb") do |image|
        image.puts(Net::HTTP.get_response(URI.parse(url)).body)
      end

      if download_extension == image_extension
        image_path
      else
        ImageManager::Base.convert_extention(download_filepath, image_extension)
      end
    end

    def unique_path(path)
      path_parts = path.match(/(.*)\.([a-z]+)$/)
      "#{path_parts[1]}_#{milli_seconds}.#{path_parts[2]}"
    end

    def milli_seconds
      Time.now.strftime('%s%L').to_i
    end
  end
end