module ImageManager
  class Base
    BUCKET_NAME = ENV["BUCKET_NAME"]

    class << self
      # def download
      # end

      def upload(filepath)
        filename = "hoge.txt"
        File.open(filepath) do |file|
          client.put_object(bucket: BUCKET_NAME, key: filename, body: file) 
        end
      end

      private

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