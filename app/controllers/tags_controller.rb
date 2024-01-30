class TagsController < ApplicationController
  before_action :set_tag, only: [:destroy]

  def destroy
    @tag.destroy
    redirect_to root_path
  end

  private

  def set_tag
    @tag = Tag.find(params[:id])
  end
end
