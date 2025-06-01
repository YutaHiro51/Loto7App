# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2025_05_26_132317) do
  create_table "loto7WinningResults", force: :cascade do |t|
    t.string "lottery_round", limit: 100, null: false
    t.integer "main_num_1", null: false
    t.integer "main_num_2", null: false
    t.integer "main_num_3", null: false
    t.integer "main_num_4", null: false
    t.integer "main_num_5", null: false
    t.integer "main_num_6", null: false
    t.integer "main_num_7", null: false
    t.integer "bonus_num_1", null: false
    t.integer "bonus_num_2", null: false
    t.string "set_ball", limit: 5, null: false
    t.date "lottery_date", null: false
    t.integer "actual_sales_amount", null: false
    t.integer "prize_1_winners", null: false
    t.integer "prize_1", null: false
    t.integer "prize_2_winners", null: false
    t.integer "prize_2", null: false
    t.integer "prize_3_winners", null: false
    t.integer "prize_3", null: false
    t.integer "prize_4_winners", null: false
    t.integer "prize_4"
    t.integer "prize_5_winners", null: false
    t.integer "prize_5", null: false
    t.integer "prize_6_winners", null: false
    t.integer "prize_6", null: false
    t.integer "carry_over", null: false
  end

  create_table "loto7_purchases", force: :cascade do |t|
    t.string "number_set", null: false
    t.integer "price", default: 300, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end
end
