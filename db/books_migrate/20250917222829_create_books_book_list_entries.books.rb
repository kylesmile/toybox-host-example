# This migration comes from books (originally 20250426000003)
class CreateBooksBookListEntries < ActiveRecord::Migration[7.1]
  def change
    create_table :book_list_entries do |t|
      t.references :book, null: false, foreign_key: true
      t.references :book_list, null: false, foreign_key: true
      t.datetime :read_at

      t.timestamps
    end

    add_index :book_list_entries, [:book_id, :book_list_id]
  end
end
