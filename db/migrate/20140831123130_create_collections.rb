class CreateCollections < ActiveRecord::Migration
  def change
    create_table :collections do |t|
      t.boolean :is_hidden, null: false, default: false
      t.integer :parent_id
      t.integer :position, null: false
      t.string :title, null: false
      t.text :description
      t.string :html_title
      t.text :meta_description
      t.string :meta_keywords
      t.string :permalink, null: false
      t.string :url, null: false
      t.text :seo_description
      t.integer :insales_id, null: false
      t.integer :insales_parent_id
      t.integer :account_id, null: false
      t.timestamps
    end
  end
end
