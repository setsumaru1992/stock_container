module ImageManager
  class IndexChart::NikkeiAndDowInLongTerm < Base
    CHART_FILENAME = "nikkei_and_dow_in_long_term.jpeg"
    IMAGE_URL = "#{S3_BUCKET_DIRECTORY_URL}/#{CHART_FILENAME}"
    class << self
      def upload(filepath)
        upload_to_s3(filepath, CHART_FILENAME)
      end
    end
  end
end