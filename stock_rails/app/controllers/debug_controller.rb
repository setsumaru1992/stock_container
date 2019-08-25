module Bot
  class DebugController < ApplicationController
    def debug
      message = "hoge"
      render json: {
        result: message
      }
    end
  end
end
