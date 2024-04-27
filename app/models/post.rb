class Post < ApplicationRecord
	belongs_to :user, dependent: :delete
end