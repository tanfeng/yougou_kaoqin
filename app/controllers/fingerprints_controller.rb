#!/usr/bin/env ruby
# encoding: utf-8
require 'spreadsheet'
class FingerprintsController < ApplicationController
  # GET /fingerprints
  # GET /fingerprints.json
  def index
    @fingerprints = Fingerprint.find_by_sql("select * from fingerprints where date(fp_time)='2013-04-01' and employee_name='闵晓荣' order by fp_time asc ")

    dofp = DayOfFP.new
    dofp.first_sign  = @fingerprints.first.fp_time
    dofp.first_sign  = @fingerprints.last.fp_time

    puts dofp

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @fingerprints }
    end
  end

  # GET /fingerprints/1
  # GET /fingerprints/1.json
  def show
    @fingerprint = Fingerprint.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @fingerprint }
    end
  end

  # GET /fingerprints/new
  # GET /fingerprints/new.json
  def new
    @fingerprint = Fingerprint.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @fingerprint }
    end
  end

  # GET /fingerprints/1/edit
  def edit
    @fingerprint = Fingerprint.find(params[:id])
  end

  # POST /fingerprints
  # POST /fingerprints.json
  def create
    @fingerprint = Fingerprint.new(params[:fingerprint])

    respond_to do |format|
      if @fingerprint.save
        format.html { redirect_to @fingerprint, notice: 'Fingerprint was successfully created.' }
        format.json { render json: @fingerprint, status: :created, location: @fingerprint }
      else
        format.html { render action: "new" }
        format.json { render json: @fingerprint.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /fingerprints/1
  # PUT /fingerprints/1.json
  def update
    @fingerprint = Fingerprint.find(params[:id])

    respond_to do |format|
      if @fingerprint.update_attributes(params[:fingerprint])
        format.html { redirect_to @fingerprint, notice: 'Fingerprint was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @fingerprint.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /fingerprints/1
  # DELETE /fingerprints/1.json
  def destroy
    @fingerprint = Fingerprint.find(params[:id])
    @fingerprint.destroy

    respond_to do |format|
      format.html { redirect_to fingerprints_url }
      format.json { head :no_content }
    end
  end

  def upload_view
  end

  def upload_excel
    excel = params[:upload]
    puts excel['datafile'].content_type
    file_name = excel['datafile'].original_filename if (excel['datafile'] != '')
    file = excel['datafile'].read()
    file_type = file_name.split(".").last
    if file_type and 'xls' != file_type
      flash[:alert] = '文件类型不正确！只允许传xls扩展类型的文件!'
      redirect_to :action => :upload_view and return

    end

    new_file_name = file_name
    new_file_name_with_type = "#{new_file_name}.#{file_type}"
    excel_root = get_upload_file_path

    if (!Dir.exist?(excel_root))
      Dir.mkdir(excel_root, 777)
    end
    File.open( get_upload_file_path+new_file_name, 'wb') do |f|
      f.write(file)
    end

    flash[:info] = file_name
    workbook = Spreadsheet.open( get_upload_file_path+new_file_name)
    sheet = workbook.worksheets[0]
    puts sheet.count
    if sheet
      sheet.each do |row|
        finger_print = Fingerprint.new
        finger_print.dept_name     = row[0]
        finger_print.employee_name = row[1]
        finger_print.employee_no   = row[2]
        finger_print.fp_time       = row[3]
        finger_print.machine       = row[4]
        finger_print.no            = row[5]
        finger_print.pattern       = row[6]
        finger_print.card_no       = row[7]
        finger_print.file_name     = new_file_name
        finger_print.save
      end
    end
    redirect_to :action => :upload_view and return
  end


  private
  def get_upload_file_path
    return Rails.root+"public/upload/"
  end

end
