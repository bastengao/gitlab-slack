class AddOmniauthToUser < ActiveRecord::Migration
  def change
    add_column :users, :provider, :string
    add_column :users, :uid, :string
    add_column :users, :access_token, :string
    add_column :users, :private_token, :string
  end
end
