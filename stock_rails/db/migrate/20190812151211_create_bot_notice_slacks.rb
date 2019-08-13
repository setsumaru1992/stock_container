class CreateBotNoticeSlacks < ActiveRecord::Migration[5.2]
  def change
    create_table :bot_notice_slacks do |t|
      t.references :user, foreign_key: true
      t.string :slack_url, null: false, default: ""

      t.timestamps
    end
  end
end
