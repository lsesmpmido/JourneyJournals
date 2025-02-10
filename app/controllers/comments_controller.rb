# frozen_string_literal: true

class CommentsController < ApplicationController
  before_action :set_comment, only: %i[edit update destroy]
  before_action :set_commentable, only: %i[create edit update]

  def create
    @comment = @commentable.comments.build(comment_params)
    @comment.user = current_user
    if @comment.save
      redirect_to @commentable, notice: t('controllers.common.notice_create', name: Comment.model_name.human)
    else
      redirect_to @commentable, alert: t('controllers.common.alert_create_failed', name: Comment.model_name.human)
    end
  end

  def edit; end

  def update
    if current_user != @comment.user
      redirect_to @commentable, alert: t('controllers.common.not_authorized')
      return
    end

    if @comment.update(comment_params)
      redirect_to @commentable, notice: t('controllers.common.notice_update', name: Comment.model_name.human)
    else
      render :edit
    end
  end

  def destroy
    return if current_user != @comment.user

    @comment.destroy
    redirect_to @commentable, notice: t('controllers.common.notice_destroy', name: Comment.model_name.human)
  end

  private

  def set_commentable
    @commentable = if params[:image_id]
                     Image.find(params[:image_id])
                   elsif params[:journal_id]
                     Journal.find(params[:journal_id])
                   end
  end

  def set_comment
    @comment = Comment.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:content)
  end
end
