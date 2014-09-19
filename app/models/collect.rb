class Collect < ActiveRecord::Base
  belongs_to :collection
  belongs_to :product
end
