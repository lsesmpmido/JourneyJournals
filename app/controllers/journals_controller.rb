# frozen_string_literal: true

require 'mini_exiftool'

class JournalsController < ApplicationController
  before_action :set_journal, only: %i[show edit update destroy]

  def index
    @journals = Journal.all
  end

  def show
    @images = @journal.images.includes(:journal).order(:date_of_shooting)
    @locations = @images.map do |image|
      { lat: image.latitude, lng: image.longitude } if image.latitude && image.longitude
    end.compact
  end

  def new
    @journal = Journal.new
    @journal.images.build
  end

  def edit; end

  def create
    @journal = current_user.journals.new(journal_params)
    @journal.images.each do |image|
      image.user_id = current_user.id
    end
    if @journal.save
      process_images(@journal.images)
      redirect_to @journal, notice: 'Journal and Image were successfully created.'
    else
      render :new
    end
  end

  def update
    if @journal.update(journal_params)
      redirect_to @journal, notice: 'Journal was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @journal.destroy
    redirect_to journals_url, notice: 'Journal was successfully destroyed.'
  end

  private

  def set_journal
    @journal = Journal.find(params[:id])
  end

  def journal_params
    params.require(:journal).permit(:journal_name, :description, images_attributes: [:file])
  end

  def process_images(images)
    images.each do |image|
      exif = extract_exif_from_image(image)
      next unless exif

      update_image_with_exif(image, exif)
    end
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

  def update_image_with_exif(image, exif)
    latitude = exif.gpslatitude
    longitude = exif.gpslongitude
    if latitude && longitude
      image.latitude = convert_to_decimal(latitude)
      image.longitude = convert_to_decimal(longitude)
    end

    date_of_shooting = exif.date_time_original || exif.create_date
    image.date_of_shooting = date_of_shooting if date_of_shooting
    image.save
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
