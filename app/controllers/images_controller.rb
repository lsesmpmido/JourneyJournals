# frozen_string_literal: true

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
      redirect_to root_url, notice: 'Add Image'
    else
      render :new
    end
  end

  private

  def image_params
    params.fetch(:image, {}).permit(:image_name, :memo, :file, :latitude, :longitude, :captured_at)
  end
end
