module WebAccessor::Sbi
  class Base < ::WebAccessor::Base
    LOGIN_URL = "https://site2.sbisec.co.jp/ETGate/?_ControlID=WPLETlgR001Control&_PageID=WPLETlgR001Rlgn50&_DataStoreID=DSWPLETlgR001Control&_ActionID=login&getFlg=on"

    def initialize(need_credential: false, user_name: nil, password: nil)
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
      accessor.find_element(:name, "user_id").send_keys(@user_name)
      accessor.find_element(:name, "user_password").send_keys(@password)
      accessor.find_element(:name, "logon").click
    end
  end
end