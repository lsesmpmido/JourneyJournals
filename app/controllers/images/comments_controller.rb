# frozen_string_literal: true

class Images::CommentsController < CommentsController
  before_action :set_commentable

  private

  def set_commentable
    @commentable = Image.find(params[:image_id])
  end
end
