class InitialSetup < ActiveRecord::Migration
  def self.up
    create_table :oauth_users, :force => true do |t|
      t.string :provider
      t.column :provider_id, :bigint
      t.integer :end_user_id
      t.string :username
      t.string :email
      t.string :first_name
      t.string :last_name
      t.string :profile_photo_url
      t.timestamps
    end

    add_index :oauth_users, [:provider, :provider_id], :unique => true
    add_index :oauth_users, [:end_user_id], :name => 'oauth_users_end_user_idx'
  end

  def self.down
    drop_table :oauth_users
  end
end
