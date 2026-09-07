class RenameGenusesToGenera < ActiveRecord::Migration[8.1]
  def change
    rename_table :genuses, :genera
  end
end
