# frozen_string_literal: true

class JournalsController < ApplicationController
  before_action :set_journal, only: %i[show edit update destroy]

  def index
    @journals = Journal.all
  end

  def show
    redirect_to images_path(journal_id: @journal.id)
  end

  def new
    @journal = Journal.new
    @journal.images.build
  end

  def edit; end

  def create
    @journal = Journal.new(journal_params)
    if @journal.save
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
end
