require_relative 'boot'

require 'rails/all'
require 'dotenv'


# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module StockRails
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2
    # 環境変数が書き変わらないときは"spring stop"シェルコマンド実行https://qiita.com/metafalse/items/7294afa3d1be3315e999
    Dotenv.load!(Rails.root.join("..", ".env"))

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    config.autoload_paths += %W(#{config.root}/app/lib)
    config.autoload_paths += %W(#{config.root}/app/application_services)
    config.autoload_paths += %W(#{config.root}/app/domains)
    config.autoload_paths += %W(#{config.root}/app/slackers)
    config.time_zone = 'Asia/Tokyo'
    config.active_record.default_timezone = :local
    config.encoding = "utf-8"

    config.generators do |g|
      g.javascripts false
      g.helper false
      g.test_framework false
    end

    config.action_mailer.default_url_options = { host: 'localhost', port: 18090 }

    config.log_formatter = proc do |severity, datetime, progname, msg|
      "[#{severity}]#{datetime}: #{progname} : #{msg}\n"
    end
    config.logger = Logger.new("/var/log/app/stock_container/stock_rails/#{Rails.env}.log", "daily")
  end
end
