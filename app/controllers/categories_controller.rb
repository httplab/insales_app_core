class CategoriesController < ApplicationController
  respond_to :json, only: :tree
  respond_to :html, except: [:tree]

  def tree
    @tree = Category.tree_hash
    respond_with @tree.to_json
  end

  def index
    @categories = Category.all
    respond_with @categories
  end

end
