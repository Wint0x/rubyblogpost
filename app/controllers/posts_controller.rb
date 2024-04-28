class PostsController < ApplicationController
	before_action :set_post, only: [:destroy]
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

	def destroy
		if not current_user
			puts "Debug"
	      render plain: '403 Forbidden', status: :forbidden
	      return
	    end

	    if not ["admin","moderator"].include? current_user.role
	    	puts "Wtf"
	    	puts current_user.role 
	      	render plain: '403 Forbidden', status: :forbidden
	      	return
	    
	    else

	       post_author = User.find(@post.user_id)

	       if post_author.role == "admin" and current_user.role != "admin"

	       		respond_to do |format| 
	       			format.html { redirect_to root_path, notice: 'Only admins can delete posts of other admins.'}
		        	format.json { head :no_content }
		        end
		    else
	  	    	@post.destroy!

		        respond_to do |format|
		        	format.html { redirect_to root_path, notice: 'Post was successfully deleted.' }
		        	format.json { head :no_content }
		        end
	    	end
	    end
    end

private
	def set_post
		@post = Post.find(params[:id])
	end

	def post_params
		params.permit(:title, :content)
	end
end