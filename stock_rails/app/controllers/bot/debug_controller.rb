module Bot
  class DebugController < ApplicationController
    def debug
      render json: {
        result: "hoge"
      }
    end
  end
end
