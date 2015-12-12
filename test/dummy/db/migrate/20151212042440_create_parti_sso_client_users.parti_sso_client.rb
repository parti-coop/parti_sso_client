# This migration comes from parti_sso_client (originally 20151212033148)
class CreatePartiSsoClientUsers < ActiveRecord::Migration
  def change
    create_table :parti_sso_client_users do |t|
      t.string :email, null: false, index: true
      t.timestamps null: false
    end
  end
end
