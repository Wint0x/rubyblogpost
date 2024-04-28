class UsersController < ApplicationController
  before_action :set_user, only: [:destroy]
  before_action :find_user_by_username, only: [:show]

  def index

    if current_user == nil
      render plain: '401 Unauthorized', status: :unauthorized
    
    elsif
      current_user.role != "admin"
      render plain: '401 Unauthorized', status: :unauthorized
    else

      @users = User.all
    end
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.role = "user"

    @user.location.downcase!
    @user.location.capitalize!

    if user_params[:profile_picture].present? && !user_params[:profile_picture].is_a?(String)

      #Security

      # Valid MIME type
      
      allowed_types = ['image/jpeg', 'image/png', 'image/gif'] # Specify allowed MIME types
      if allowed_types.include?(user_params[:profile_picture].content_type) and validate_extension(user_params[:profile_picture])
        @user.profile_picture.attach(user_params[:profile_picture])
      else
        flash[:error] = "Only JPEG, PNG, and GIF files are allowed for profile pictures."
        render :new, status: :unprocessable_entity
        return
      end

    else
      @user.profile_picture.attach(io: File.open("app/assets/images/guest_user.png"), filename: "guest_user.png", content_type: "image/png")

    end

    # Already authenticated
    if current_user and current_user.role != "admin"
      flash[:alert] = "You're trying to create an account while already logged in, consider logging out first!"
      render :new, status: :bad_request
      return
    end

    if @user.save
      flash[:notice] = "User created successfully"
      redirect_to root_path
    else
      flash[:alert] = @user.errors.full_messages.first || "User creation failed" # Print the first error message
      render :new, status: :unprocessable_entity
    end
  end

  # DELETE HTTP
  def destroy

    if not current_user
      render plain: '403 Forbidden', status: :forbidden
      return
    end

    if current_user.role != "admin"
      render plain: '403 Forbidden', status: :forbidden
      return
    end

    # Cannot delete admin!
    if @user.id == 1
      respond_to do |format|
        format.html {redirect_to users_url, notice: 'Cannot delete admin!'}
        format.json { head :no_content}
      end

    else
      @user.destroy!
      respond_to do |format|
        format.html { redirect_to users_url, notice: 'User was successfully deleted.' }
        format.json { head :no_content }
      end
    end
  end

  def show
    
  end

  private

  def user_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation, :profile_picture, :location, :bio)
  end

  def set_user
    @user = User.find(params[:id])
  end

  def find_user_by_username
    @user = User.find_by(username: params[:username])

    if @user.nil?
      flash[:alert] = "User not found"
      redirect_to root_path
    end
  end

  def validate_extension(file)
    @ALLOWED_EXTENSIONS = %w[.jpg .jpeg .png .gif]
    extension = File.extname(file.original_filename).downcase
    @ALLOWED_EXTENSIONS.include?(extension)
  end
end