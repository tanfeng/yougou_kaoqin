class Fingerprint < ActiveRecord::Base
  attr_accessible :card_no, :dept_name, :employee_name, :employee_no, :file_name, :fp_time, :machine, :no, :pattern
end
