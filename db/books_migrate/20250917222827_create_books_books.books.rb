# This migration comes from books (originally 20250426000001)
class CreateBooksBooks < ActiveRecord::Migration[7.1]
  def change
    create_table :books do |t|
      t.string :title, null: false
      t.string :author, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :books, [:title, :author, :user_id], unique: true
  end
end
