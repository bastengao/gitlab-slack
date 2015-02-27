class CreateWebhooks < ActiveRecord::Migration
  def change
    create_table :webhooks do |t|
      t.string :name, null: false
      t.string :slack_incoming_hook
      t.references :user, index: true, null: false

      t.timestamps null: false
    end
    add_foreign_key :webhooks, :users
  end
end
