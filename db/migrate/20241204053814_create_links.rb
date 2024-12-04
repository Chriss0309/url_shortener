class CreateLinks < ActiveRecord::Migration[8.0]
  def change
    create_table :links do |t|
      t.string :target__url
      t.string :short_path
      t.string :title

      t.timestamps
    end
  end
end
