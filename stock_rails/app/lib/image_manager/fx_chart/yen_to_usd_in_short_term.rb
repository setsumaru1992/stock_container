module ImageManager
  class FxChart::YenToUsdInShortTerm < Base
    CHART_FILENAME = "fx_yen_to_usd_in_short_term_chart.jpeg"
    IMAGE_URL = "#{S3_BUCKET_DIRECTORY_URL}/#{CHART_FILENAME}"
    class << self
      def upload(filepath)
        upload_to_s3(filepath, CHART_FILENAME)
      end
    end
  end
end