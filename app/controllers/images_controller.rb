# frozen_string_literal: true

require 'mini_exiftool'
require 'time'
require 'geocoder'
Geocoder.configure(language: :ja)

class ImagesController < ApplicationController
  before_action :set_image, only: %i[show edit update destroy]
  before_action :check_ownership, only: %i[edit update destroy]

  def index
    @images = Image.all.includes(:journal).order(:date_of_shooting)
    @grouped_images = @images.group_by { |image| image.date_of_shooting.in_time_zone('Asia/Tokyo').to_date }
  end

  def show
    @comment = Comment.new
    @comments = @image.comments
  end

  def new
    @journal = Journal.find(params[:journal_id])
    @image = Image.new
  end

  def edit; end

  def create
    @image = current_user.images.new(image_params)
    @image.user_id = current_user.id
    @image.image_name = @image.image_name.presence || @image.file.filename.to_s
    if @image.save
      exif = extract_exif_from_image(@image)
      if exif
        if exif.gpslatitude && exif.gpslongitude
          @image.latitude = convert_to_decimal(exif.gpslatitude)
          @image.longitude = convert_to_decimal(exif.gpslongitude)
          result = Geocoder.search([@image.latitude, @image.longitude]).first.address
          @image.address = result.split(', ').slice(0..-3).reverse.join(' ')
        end
        @image.date_of_shooting = exif.date_time_original || exif.create_date
        @image.save
      end
      redirect_to journal_path(@image.journal_id), notice: t('controllers.common.notice_create', name: Image.model_name.human)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if params[:image][:date_of_shooting].present?
      Time.zone = 'Asia/Tokyo'
      date_in_tokyo = Time.zone.parse(params[:image][:date_of_shooting])
      @image.date_of_shooting = date_in_tokyo.utc
    end

    if @image.update(image_params)
      if @image.latitude || @image.longitude
        result = Geocoder.search([@image.latitude, @image.longitude]).first.address
        @image.address = result.split(', ').slice(0..-3).reverse.join(' ')
        @image.save
      end
      redirect_to @image, notice: t('controllers.common.notice_update', name: Image.model_name.human)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @image.destroy

    redirect_to journal_path(@image.journal_id), notice: t('controllers.common.notice_destroy', name: Image.model_name.human)
  end

  private

  def set_image
    @image = Image.find(params[:id])
  end

  def image_params
    params.require(:image).permit(:image_name, :memo, :file, :latitude, :longitude, :date_of_shooting, :address, :weather, :memo_image, :journal_id)
  end

  def extract_exif_from_image(image)
    file = image.file.download

    tmp_file = Tempfile.new(['exif', '.jpg'])
    tmp_file.binmode
    tmp_file.write(file)
    tmp_file.rewind

    exif = MiniExiftool.new(tmp_file.path)
    tmp_file.close

    exif
  end

  def convert_to_decimal(degree_string)
    parts = degree_string.split
    degrees = parts[0].to_i
    minutes = parts[2].delete("'").to_i
    seconds = parts[3].delete('"').to_f
    direction = parts[4]

    decimal = degrees + (minutes / 60.0) + (seconds / 3600.0)
    decimal = -decimal if %w[S W].include?(direction)

    decimal.round(4)
  end

  def check_ownership
    return if @image.journal.user_id == current_user.id

    redirect_to images_url, alert: t('controllers.common.alert_not_owner', name: Image.model_name.human)
  end
end
