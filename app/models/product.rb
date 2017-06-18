class Product < ApplicationRecord
  # 新增/修改栏位限制与提示
  validates :title, presence: { message: "请输入商品名称" }
  validates :price, presence: { message: "请输入商品价格" }
  validates :price, numericality: { greater_than: 0, message: "请输入商品价格，必须大于零" }
  validates :quantity, presence: { message: "请输入库存数量" }, numericality: { greater_than_or_equal: 0 }
  validates :category_id, presence: { message: "请选择商品细分品类" }
  validates :brand_id, presence: { message: "请选择商品品牌" }

  # 关联
  belongs_to :category
  belongs_to :brand
  has_one :order_item
  has_many :product_images, dependent: :destroy
  accepts_nested_attributes_for :product_images
  has_many :wish_lists
  has_many :wish_list_owners, :through => :wish_lists, :source => :user

  # 检查 is_hidden 的 boolean 值
  def hidden?
    is_hidden
  end

  # 发布 / 隐藏
  def publish!
    self.is_hidden = false
    self.save
  end

  def hide!
    self.is_hidden = true
    self.save
  end

  def to_param
    "#{self.id}-#{self.name.gsub(/\s+/, "")}"
  end

  # Scope
  scope :published, -> { where(is_hidden: false) }
  scope :recent, -> { order('created_at DESC') }  
end
