# frozen_string_literal: true
class AddOrganisationsTable < ActiveRecord::Migration[7.2]
  def change
    create_table :organisations do |t|
      t.integer :system_identifier, index: { unique: true, name: "unique_organisations" }
      t.string :name
      t.string :woo_email
      t.timestamps
    end
  end
end
