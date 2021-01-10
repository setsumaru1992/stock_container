module ImageManager
  class Base
    BUCKET_NAME = ENV["BUCKET_NAME"]
    S3_BUCKET_DIRECTORY_URL = "https://kibotsu-stock-images.s3-ap-northeast-1.amazonaws.com"

    class << self

      private
      # def download_to_s3
      # end

      def upload_to_s3(upload_source_path, upload_destination_path)
        File.open(upload_source_path) do |file|
          client.put_object(
            bucket: BUCKET_NAME, 
            key: upload_destination_path, 
            body: file,
            cache_control: "no-cache",
            acl: "public-read"
          ) 
        end
      end

      def client
        Aws::S3::Client.new(
          region: "ap-northeast-1",
          access_key_id: ENV["AWS_STOCK_ADMIN_ACCESS_KEY"],
          secret_access_key: ENV["AWS_STOCK_ADMIN_SECRET_ACCESS_KEY"]
          )
      end
    end
  end
end