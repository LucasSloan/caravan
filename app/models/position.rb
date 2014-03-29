class Position < ActiveRecord::Base
  belongs_to :user
  default_scope :order => "timestamp DESC"
end
