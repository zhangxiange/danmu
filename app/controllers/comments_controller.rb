class CommentsController < ApplicationController
  before_action :set_comment, only: [:show, :edit, :update, :destroy]
  def index
    @comments = policy_scope(Comment).order(created_at: :ASC)
    @slide = Slide.includes(comments: :user).find(params[:slide_id])
  end
  def new
    @slide = Slide.find(params[:slide_id])
    @comment = Comment.new
    authorize @comment
  end
  def create
    @comment = Comment.new(comment_params)
    @slide = Slide.find(params[:slide_id])
    @comment.slide = @slide
    @comment.user = current_user
    authorize(@comment)
    if @comment.save
      ActionCable.server.broadcast("slide_#{@slide.id}", {
        comment: (@comment.content), color: (@comment.color) }
      )
      render :new
    else
      render :new
      flash[:notice] = "please enter a comment"
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:content, :color)
  end

  def set_comment
    @comment = Comment.find(params[:id])
    authorize @comment
  end
end