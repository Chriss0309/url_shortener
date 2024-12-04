class CreateVisits < ActiveRecord::Migration[8.0]
  def change
    create_table :visits do |t|
      t.references :link, null: false, foreign_key: true
      t.string :ip_address
      t.string :user_agent
      t.string :referer
      t.string :country
      t.string :city
      
      t.timestamps
    end
  end
end
