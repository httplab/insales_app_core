class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.integer :insales_id, null: false
      t.string :title, null: false
      t.boolean :available, null: false
      t.integer :canonical_url_collection_id
      t.integer :category_id
      t.integer :insales_category_id
      t.text :description
      t.text :html_title
      t.boolean :is_hidden, null: false
      t.string :meta_description
      t.string :meta_keywords
      t.string :permalink
      t.string :short_description
      t.integer :account_id, null: false
      t.timestamps
    end
  end
end
