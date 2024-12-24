# frozen_string_literal: true

require 'mini_exiftool'
require 'time'

class ImagesController < ApplicationController
  before_action :set_image, only: %i[show edit update destroy]

  def index
    @images = Image.all.includes(:journal)
  end

  def show; end

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
        end
        @image.date_of_shooting = exif.date_time_original || exif.create_date
        @image.save
      end
      redirect_to journal_path(@image.journal_id), notice: 'Image was successfully added.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    respond_to do |_format|
      if @image.update(image_params)
        redirect_to @image, notice: t('controllers.common.notice_update', name: Image.model_name.human)
      else
        render :edit, status: :unprocessable_entity
      end
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
    params.require(:image).permit(:image_name, :memo, :file, :latitude, :longitude, :date_of_shooting, :journal_id)
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
end
