class RenameTargetUrlColumn < ActiveRecord::Migration[8.0]
  def change
    rename_column :links, :target__url, :target_url
  end
end
