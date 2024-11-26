# frozen_string_literal: true

require 'mini_exiftool'
require 'time'

class ImagesController < ApplicationController
  def index
    @images = Image.all
  end

  def show
    @image = Image.find(params[:id])
  end

  def new
    @image = Image.new
  end

  def create
    @image = Image.new(image_params)
    @image.image_name = @image.file.filename.to_s

    if @image.save
      exif = extract_exif_from_image(@image)
      if exif
        latitude = exif.gpslatitude
        longitude = exif.gpslongitude
        if latitude && longitude
          @image.latitude = convert_to_decimal(latitude)
          @image.longitude = convert_to_decimal(longitude)
        end
        date_of_shooting = exif.date_time_original || exif.create_date
        @image.date_of_shooting = date_of_shooting.in_time_zone('Asia/Tokyo') if date_of_shooting
        @image.save
      end
      redirect_to root_url, notice: 'Add Image'
    else
      render :new
    end
  end

  private

  def image_params
    params.fetch(:image, {}).permit(:image_name, :memo, :file, :latitude, :longitude, :date_of_shooting)
  end

  # Active StorageのファイルからEXIF情報を取得するメソッド
  def extract_exif_from_image(image)
    # Active Storageのファイルを一時的にローカルに保存
    file = image.file.download

    # 一時ファイルを作成
    tmp_file = Tempfile.new(['exif', '.jpg'])
    tmp_file.binmode
    tmp_file.write(file)
    tmp_file.rewind

    # Exif情報をMiniExiftoolで読み取る
    exif = MiniExiftool.new(tmp_file.path)
    tmp_file.close # 一時ファイルを閉じる

    # 位置情報を取得
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
