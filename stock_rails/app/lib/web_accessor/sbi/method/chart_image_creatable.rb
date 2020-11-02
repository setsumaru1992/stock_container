module WebAccessor::Sbi
  module Method::ChartImageCreatable
    def get_concated_price_chart_image_path_in_iframe(iframe_xpath, chart_settings, image_name, image_dir, image_extension: "jpeg")
      switch_to_iframe(iframe_xpath)
      image_paths = chart_settings.map do |chart_setting|
        get_price_chart_image_path_in_iframe(chart_setting, image_dir, image_name, image_extension)
      end
      return image_paths.first if image_paths.size == 1
      concate_images(image_paths, unique_path("#{image_dir}/#{image_name}.#{image_extension}"))
    end

    def get_price_chart_image_path_in_iframe(chart_setting, image_dir, image_name, image_extension)
      click_js_trigger(
        selector: "//*[@id='MAINAREA01']/div/div/div/div/div[1]/ul/li[#{chart_setting.range_tab_idx_for_xpath}]/a",
        wait_target_by: :xpath,
        wait_target_selector: "//img[@id='chartImg']"
      )
      if chart_setting.chart_unit.present?
        click_chart_selectbox("//*[@id='periodicity']", chart_setting.chart_unit_select_value)
      end
      if chart_setting.first_technical.present?
        click_chart_selectbox("//*[@id='technicalUpper']", chart_setting.first_technical_select_value)
      end
      if chart_setting.second_technical.present?
        click_chart_selectbox("//*[@id='technicalLower']", chart_setting.second_technical_select_value)
      end

      image_url = @accessor.find_element(:xpath, "//img[@id='chartImg']").attribute("src")
      image_path = unique_path("#{image_dir}/#{image_name}_#{chart_setting.range_key.to_s.downcase}.#{image_extension}")
      download_image_from(image_url, image_path, "gif")
    end

    def click_chart_selectbox(xpath, value)
      selectbox_element = @accessor.find_element(:xpath, xpath)
      select = ::Selenium::WebDriver::Support::Select.new(selectbox_element)
      select.select_by(:value, value)
      sleep(1)
    end
  end
end