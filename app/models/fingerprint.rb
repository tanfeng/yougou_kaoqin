class Fingerprint < ActiveRecord::Base
  attr_accessible :card_no, :dept_name, :employee_name, :employee_no, :file_name, :fp_time, :machine, :no, :pattern
  def get_fp_by_day(fp_time,employee_name)
    @fingerprints = Fingerprint.find_by_sql("select * from fingerprints where date(fp_time)='#{fp_time}' and employee_name='#{employee_name}'  order by fp_time asc ")
    return @fingerprints
  end

  def get_employees(year_month)
    puts year_month
    @employees = Fingerprint.find_by_sql("select distinct employee_name from fingerprints  where date_format(fp_time, '%Y-%m') = '#{year_month}' ")
    return @employees
  end
end
