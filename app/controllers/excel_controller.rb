#!/usr/bin/env ruby
# encoding: utf-8
require 'spreadsheet'
class ExcelController < ApplicationController
  include ApplicationHelper

  def index
    @all_month = ActiveRecord::Base.connection.execute("select distinct date_format(fp_time,'%Y-%m') from fingerprints order by fp_time desc ", :as => :array)
  end

  def export
    fp = params[:fingerprint]
    if fp == nil or fp[:fp_time] == nil or fp[:fp_time].split('-').length != 2
      redirect_to :action => :index and return
    end
    year_month= fp[:fp_time].split('-')
    year =year_month[0].to_i
    month = year_month[1].to_i
    get_excel_content(year, month)
    send_file("#{get_upload_file_path}/#{year}-#{month}-汇总.xls", :type => 'application/vnd.ms-excel; charset=utf-8', :status => 200)
  end

  def upload_excel
    begin
      excel = params[:upload]
      #puts excel['datafile'].content_type
      file_name = excel['datafile'].original_filename if (excel['datafile'] != '')
      file = excel['datafile'].read()
      file_type = file_name.split(".").last

      filename = file_name.split(".").first

      if  /201\d{1}-\d{1,2}/.match(file_name.split(".").first) == nil or filename.length != 7
        flash[:alert] = "文件名称不正确，文件名称必须是2013-04这样的格式！<br/>您上传的文件名是:[#{file_name.split(".").first}]".html_safe
        redirect_to :action => :index and return
      end

      if file_type and 'xls' != file_type
        flash[:alert] = '文件类型不正确！只允许传xls扩展类型的文件!'
        redirect_to :action => :index and return
      end

      new_file_name = file_name
      new_file_name_with_type = "#{new_file_name}.#{file_type}"
      excel_root = get_upload_file_path

      if (!Dir.exist?(excel_root))
        Dir.mkdir(excel_root, 777)
      end
      File.open(get_upload_file_path+new_file_name, 'wb') do |f|
        f.write(file)
      end

      flash[:info] = file_name
      workbook = Spreadsheet.open(get_upload_file_path+new_file_name)
      sheet = workbook.worksheets[0]
      #puts sheet.count
      values = []
      if sheet
        sheet.each do |row|
          finger_print = Fingerprint.new
          finger_print.dept_name = row[0]
          finger_print.employee_name = row[1]
          finger_print.employee_no = row[2]
          finger_print.fp_time = row[3]
          finger_print.machine = row[4]
          finger_print.no = row[5]
          finger_print.pattern = row[6]
          finger_print.card_no = row[7]
          finger_print.file_name = new_file_name
          #query if exist before save to db
          count = Fingerprint.where(:dept_name => row[0], :employee_name => row[1], :employee_no => row[2], :fp_time => row[3]).count

          if count < 1
            #finger_print.save
            now = DateTime.parse(Time.new.to_s).strftime('%Y-%m-%d %H:%M:%S')
            values << "('#{finger_print.card_no}' , '#{finger_print.dept_name}', '#{finger_print.employee_name}', #{finger_print.employee_no}, '#{finger_print.file_name}','#{finger_print.fp_time.strftime('%Y-%m-%d %H:%M:%S')}', #{finger_print.machine},
                      '#{finger_print.no}', '#{finger_print.pattern}' ,'#{now}','#{now}')"
          else
            puts "exist record [ #{row} ] will not be insert into database repeat !"
          end
        end
      end

      sql = "INSERT INTO fingerprints (card_no,  dept_name, employee_name, employee_no, file_name, fp_time, machine, no, pattern , created_at , updated_at) VALUES #{values.join(',')} "
      ActiveRecord::Base.connection.execute(sql)

    rescue Ole::Storage::FormatError
      flash[:alert] = 'excel格式不正确，请打开后另存为副本再进行上传！'
      redirect_to :action => :index and return
    end

    redirect_to :action => :upload_view and return
  end


  private
  def get_upload_file_path
    return Rails.root+"public/upload/"
  end

  def days_in_month(year, month)
    (Date.new(year, 12, 31) << (12-month)).day
  end

  def get_excel_content(year, month)
    @fp = Fingerprint.new
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet(:name => "#{year}-#{month}")
    header_format = Spreadsheet::Format.new(:align => :merge)
    format = Spreadsheet::Format.new :color => :red, :pattern_fg_color => :yellow, :pattern => 1
    format_gray = Spreadsheet::Format.new :color => :gray, :pattern => 1

    header_row = sheet1.row(0)
    header_row2 = sheet1.row(1)
    total_days = days_in_month(year, month)
    (total_days*2).times do |i|
      header_row.set_format(i+1, header_format)
      if (i+1)%2==1
        header_row2[i+1, 1] = '上班'
      else
        header_row2[i+1, 1] = '下班'
      end
    end
    header_row[0, 0] = "姓名"

    (0..total_days).each_with_index do |day, index|
      if index > 0
        date = "#{year}-#{month}-#{day}"
        day_of_week = DateTime.parse(date).strftime("%u")
        header_row[index*2-1, 0] = "#{month}月#{day}日(星期#{day_of_week})"
      end
    end

    year_month = month <10 ? "#{year}-0#{month}" : "#{year}-#{month}"
    @fp.get_employees("2013-04").each_with_index do |item, index_1|
      row = sheet1.row(index_1+2)
      name = item.employee_name
      (0..total_days).each_with_index do |day, index|
        #puts "#{name} #{day}"
        if index==0
          row[0, 2] = name
        else
          morning_sign_1 = DateTime.parse("#{year}-#{month}-#{day} 09:01:00l")
          morning_sign_2 = DateTime.parse("#{year}-#{month}-#{day} 09:31:00 +0800")

          afternoon_sign_1 = DateTime.parse("#{year}-#{month}-#{day} 17:59:00 +0800")
          afternoon_sign_2 = DateTime.parse("#{year}-#{month}-#{day} 18:29:00 +0800")
          date = "#{year}-#{month}-#{day}"
          result = @fp.get_fp_by_day("#{date}", name)
          first = ""
          last = ""
          if result
            if result.first
              first = result.first.fp_time
            end
            if result.last
              last = result.last.fp_time
            end
          end

          tmp1 = Time.at(first.to_i) + 3600
          if first == last
            tmp1 = first
          end


          tmp2 = first
          up = (day-1)*2 +1
          down =(day*2)

          if first == '' or DateTime.parse(first.to_s) >afternoon_sign_1 or DateTime.parse(first.to_s) > afternoon_sign_2
            first = "未"
            row.set_format(up, format)
          elsif DateTime.parse(first.to_s) > morning_sign_2
            puts "#{DateTime.parse(first.to_s)}--#{morning_sign_2}"
            first = first.strftime("%Y-%m-%d %H:%M:%S")
            row.set_format(up, format)
          else
            first = '√'
          end

          if (last == '' or DateTime.parse(last.to_s) < morning_sign_1 or DateTime.parse(last.to_s) < morning_sign_2 or (DateTime.parse(tmp1.to_s) < morning_sign_2 and DateTime.parse(tmp1.to_s) > DateTime.parse(last.to_s)))
            last = "未"
            row.set_format(down, format)
          elsif DateTime.parse(last.to_s) < afternoon_sign_1 or ((DateTime.parse(tmp2.to_s) <morning_sign_2 and DateTime.parse(tmp2.to_s) > morning_sign_1) and DateTime.parse(last.to_s) < afternoon_sign_2)
            if DateTime.parse(tmp1.to_s) > DateTime.parse(last.to_s)
              last = "未"
            else
              last = last.strftime("%Y-%m-%d %H:%M:%S")
            end
            row.set_format(down, format)
          else
            last = '√'
          end
          row[up, 2] = first
          row[down, 2] = last
        end
      end
    end

    book.write(get_upload_file_path+"#{year}-#{month}-汇总.xls")
  end


end
