class Mention < ApplicationRecord
  belongs_to :user
  belongs_to :mentionable, polymorphic: true

end
