class PostsController < ApplicationController
	before_action :post_params, only: [:create]

	def new
		@post.new
	end

	def index
		@users = User.all.includes(:posts)
		return if @users.empty?

		# Query to get the most recent post for each user
		@posts = @users.map do |user|
		  user.posts.order(created_at: :desc).first
		end

	end

	def create
	  if current_user.blank? # or use a method provided by your authentication system
	    flash[:notice] = "You need to be logged in to post something!"
	    redirect_to(user_sessions_new_path)
	    return
	  end

	  @post = current_user.posts.build(post_params)

	  if @post.save
		 flash[:notice] = "Post created successfully"
		 redirect_to root_path
	  else
		  flash[:warn] = "Could not create post"
		  redirect_to root_path
	  end
	end

private
	def post_params
		params.permit(:title, :content)
	end
end