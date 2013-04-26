class CreateFingerprints < ActiveRecord::Migration
  def change
    create_table :fingerprints do |t|
      t.string :dept_name
      t.string :employee_name
      t.integer :employee_no
      t.date :fp_time
      t.integer :machine
      t.string :no
      t.string :pattern
      t.string :card_no
      t.string :file_name

      t.timestamps
    end
  end
end
