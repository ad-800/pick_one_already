class CreateMovies < ActiveRecord::Migration[7.0]
  def change
    create_table :movies do |t|
      t.string "title"
      t.text "overview"
      t.string "poster_url"
      t.integer "rtscore"
      t.integer "mcscore"
      t.string "cast"
      t.string "year"
      t.boolean "saved", default: false
      t.integer "rtauscore"
      t.string "video"
      t.timestamps
    end
  end
end
