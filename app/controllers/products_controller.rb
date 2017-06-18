class ProductsController < ApplicationController
  def index
    # 商品大型 / 品牌
    @category_groups = CategoryGroup.published
    @brands = Brand.published

    # 判斷是否筛选细分品类
    if params[:category].present?
      @category_s = params[:category]
      @category = Category.find_by(name: @category_s)
      @products = Product.where(:category => @category.id).published.paginate(:page => params[:page], :per_page => 12)

    # 判斷是否筛选大类
    elsif params[:group].present?
      @group_s = params[:group]
      @group = CategoryGroup.find_by(name: @group_s)
      @products = Product.joins(:category).where("categories.category_group_id" => @group.id).published.paginate(:page => params[:page], :per_page => 12)

    # 判斷是否筛选品牌
    elsif params[:brand].present?
      @brand_s = params[:brand]
      @brand = Brand.find_by(name: @brand_s)
      @products = Product.where(:brand => @brand.id).published.paginate(:page => params[:page], :per_page => 12)

    # 默认显示所有公开发布的商品
    else
      @products = Product.published.paginate(:page => params[:page], :per_page => 12)
    end
  end

  def show
    @product = Product.find(params[:id])
    @product_images = @product.product_images.all
    @orderSum = OrderItem.where("product_id" => @product.id).sum(:quantity)
    @product_stock = @product.quantity - @orderSum

    # 大类 / 品牌
    @category_groups = CategoryGroup.published.paginate(:page => params[:page], :per_page => 12)
    @brands = Brand.published

    set_page_title       @product.title
    set_page_description @product.description
    set_page_keywords    @product.title
    set_page_image       @product_images.first.image.main.url
  end

  def add_to_cart
    @product = Product.find(params[:id])
    if !current_cart.products.include?(@product)
      current_cart.add_product_to_cart(@product)
      flash[:notice] = t('message-add-to-cart-success')
    else
      flash[:warning] = t('message-already-added')
    end
    redirect_to :back
  end
end
