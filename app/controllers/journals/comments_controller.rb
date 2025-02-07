# frozen_string_literal: true

class Journals::CommentsController < CommentsController
  before_action :set_commentable

  private

  def set_commentable
    @commentable = Journal.find(params[:journal_id])
  end
end
