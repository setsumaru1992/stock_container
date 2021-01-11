module ImageManager
  class Base
    BUCKET_NAME = ENV["BUCKET_NAME"]
    S3_BUCKET_DIRECTORY_URL = "https://kibotsu-stock-images.s3-ap-northeast-1.amazonaws.com"

    class << self
      # TODO: 見通しが悪くなってきたら、ImageConvertableに詰める
      def concate_images(image_paths, save_path)
        MiniMagick::Tool::Convert.new do |convert|
          convert.append.-
          image_paths.each do |image_path|
            convert << image_path
          end
          convert << save_path
        end
  
        image_paths.each do |image_path|
          FileUtils.rm(image_path)
        end
  
        save_path
      end

      def convert_extention(original_file_path, extention)
        # TODO: 今はこれ(jpeg.gifなど拡張子が連なる形)で動いているのでこの記法。使い方ともに修正したい
        converted_file_path = "#{original_file_path}.#{extention}"

        image = MiniMagick::Image.open(original_file_path)
        image.format(extention)
        image.write(converted_file_path)
        FileUtils.rm(original_file_path)
        converted_file_path
      end

      def extension_of(path)
        path.match(/\.([a-z]+)$/)[1]
      end

      private
      
      # TODO: 将来的にS3ImageUploadableAndDownloadableに詰める
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