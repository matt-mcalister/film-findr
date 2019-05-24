class CreateDownloads < ActiveRecord::Migration[5.1]
  def change
    create_table :downloads do |t|
      t.string :torrent_hash
      t.string :title
      t.boolean :isLocal
      t.string :mediaType
      t.integer :season
      t.integer :episode

      t.timestamps
    end
  end
end
