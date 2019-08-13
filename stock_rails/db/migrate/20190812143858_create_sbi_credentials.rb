class CreateSbiCredentials < ActiveRecord::Migration[5.2]
  def change
    create_table :sbi_credentials do |t|
      t.references :user, foreign_key: true
      t.string :user_name, null: false, default: ""
      t.string :read_password, null: false, default: ""

      t.timestamps
    end
  end
end
