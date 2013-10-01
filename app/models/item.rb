class Item < ActiveRecord::Base
  # TODO: 他のモデルと関連を持つようにする
  has_many :inverts
end
