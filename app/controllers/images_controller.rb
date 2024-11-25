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
        captured_at = exif.date_time_original || exif.create_date
        @image.captured_at = captured_at.in_time_zone('Asia/Tokyo') if captured_at
        @image.save
      end
      redirect_to root_url, notice: 'Add Image'
    else
      render :new
    end
  end

  private

  def image_params
    params.fetch(:image, {}).permit(:image_name, :memo, :file, :latitude, :longitude, :captured_at)
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
    # 例: "31 13 51.9400000000023"（度 分 秒）
    parts = degree_string.split(' ')
    degrees = parts[0].to_f
    minutes = parts[1].to_f / 60
    seconds = parts[2].to_f / 3600

    # 小数に変換
    degrees + minutes + seconds
  end
end
