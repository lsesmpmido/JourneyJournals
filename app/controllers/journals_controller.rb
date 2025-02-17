# frozen_string_literal: true

require 'mini_exiftool'

class JournalsController < ApplicationController
  before_action :set_journal, only: %i[show edit update destroy]
  before_action :check_ownership, only: %i[edit update destroy]

  def index
    @journals = Journal.all
  end

  def show
    @images = @journal.images.includes(:journal).order(:date_of_shooting)
    @grouped_images = @images.group_by do |image|
      image.date_of_shooting&.in_time_zone('Asia/Tokyo')&.strftime('%Y年%m月%d日')
    end
    @locations = @images.map do |image|
      { lat: image.latitude, lng: image.longitude } if image.latitude && image.longitude
    end.compact
    @comment = Comment.new
    @comments = @journal.comments
  end

  def new
    @journal = Journal.new
    @journal.images.build
  end

  def edit; end

  def create
    @journal = current_user.journals.new(journal_params)
    preprocess_images(@journal.images) if @journal.images.any?
    if @journal.save
      postprocess_images(@journal.images) if @journal.images.any?
      redirect_to @journal, notice: t('controllers.common.notice_create', name: Journal.model_name.human)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @journal.update(journal_params)
      redirect_to @journal, notice: t('controllers.common.notice_update', name: Journal.model_name.human)
    else
      render :edit
    end
  end

  def destroy
    @journal.destroy
    redirect_to journals_url, notice: t('controllers.common.notice_destroy', name: Journal.model_name.human)
  end

  private

  def set_journal
    @journal = Journal.find(params[:id])
  end

  def journal_params
    params.require(:journal).permit(:journal_name, :description, images_attributes: [:file])
  end

  def preprocess_images(images)
    images.each do |image|
      image.image_name ||= image.file.filename.to_s
      image.user_id = current_user.id
    end
  end

  def postprocess_images(images)
    images.each do |image|
      exif = extract_exif_from_image(image)
      update_image_with_exif(image, exif) if exif
      image.save
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

  def check_ownership
    return if @journal.user_id == current_user.id

    redirect_to journals_url, alert: t('controllers.common.alert_not_owner', name: Journal.model_name.human)
  end
end
