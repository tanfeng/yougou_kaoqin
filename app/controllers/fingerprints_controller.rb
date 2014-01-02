#!/usr/bin/env ruby
# encoding: utf-8
require 'spreadsheet'
class FingerprintsController < ApplicationController
  # GET /fingerprints
  # GET /fingerprints.json
  def index
    @fingerprints =[] #Fingerprint.find_by_sql("select * from fingerprints where date(fp_time)='2013-04-01' and employee_name='闵晓荣' order by fp_time asc ")
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

  def non_work_day
    @employee_name = params[:employee_name]
    puts @employee_name
    @fingerprints = []
    if request.post?
      @fingerprints = Fingerprint.find_by_sql("select distinct * from fingerprints where employee_name='#{@employee_name}' and WEEKDAY(fp_time) >=5  order by fp_time asc",:as => :array)
    end
  end

  def work_day
    @employee_name = params[:employee_name]
    @fp_time = params[:fp_time]
    if @fp_time == nil or @fp_time == ''
      @fp_time = Time.now.strftime("%Y-%m")
    end
    @fingerprints =[]
    if request.post?
      @fingerprints = Fingerprint.find_by_sql("select * from fingerprints where date_format(fp_time, '%T') >= '20:00:00' and date_format(fp_time, '%Y-%m')='#{@fp_time}' and employee_name='#{@employee_name}'")
    end
    puts @employee_name
  end

end
