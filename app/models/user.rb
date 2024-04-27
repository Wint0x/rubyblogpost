class User < ApplicationRecord
	has_secure_password
	has_one_attached :profile_picture
	validate :password_complexity
	validate :valid_location

	  # Validation for email format
	  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
	  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: VALID_EMAIL_REGEX }
	  validates :username, presence: true, uniqueness: { case_sensitive: false }

	  validates :password, confirmation: true
	  validates :password_confirmation, :presence => true

	  validates :role, presence: true, inclusion: {in: %w(user admin moderator) }

	  validates :bio, length: { maximum: 150 }
	  validates :bio, format: { with: /\A[\w\s.,!?]+\z/, message: "only allows letters, numbers, spaces, and punctuation" }

	  # Associations
	  has_many :posts


	private
	def password_complexity
	  if password.present? and !password.match(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$/)
	    errors.add :password, "must include at least one lowercase letter, one uppercase letter, one digit, and needs to be minimum 8 characters."
	  end
	end

	 def valid_location
	    countries_file = Rails.root.join('app/assets/config/countries.txt')
	    countries = File.readlines(countries_file).map(&:chomp)
	    unless countries.include?(location)
	      errors.add(:location, "is not valid")
	    end
	 end


end
