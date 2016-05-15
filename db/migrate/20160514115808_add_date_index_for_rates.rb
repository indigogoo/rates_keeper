class AddDateIndexForRates < ActiveRecord::Migration
  def change
    add_index :rates, :date
  end
end
