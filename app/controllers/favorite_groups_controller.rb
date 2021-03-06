class FavoriteGroupsController < ApplicationController
  before_filter :member_only, :except => [:index, :show]
  respond_to :html, :xml, :json, :js

  def index
    @favorite_groups = FavoriteGroup.search(params[:search]).order("updated_at desc").paginate(params[:page], :limit => params[:limit], :search_count => params[:search])
    respond_with(@favorite_groups) do |format|
      format.xml do
        render :xml => @favorite_groups.to_xml(:root => "favorite-groups")
      end
    end
  end

  def show
    @favorite_group = FavoriteGroup.find(params[:id])
    @post_set = PostSets::FavoriteGroup.new(@favorite_group, params[:page])
    respond_with(@favorite_group)
  end

  def new
    @favorite_group = FavoriteGroup.new
    respond_with(@favorite_group)
  end

  def create
    @favorite_group = FavoriteGroup.create(params[:favorite_group])
    respond_with(@favorite_group) do |format|
      format.html do
        if @favorite_group.errors.any?
          render :action => "new"
        else
          redirect_to favorite_groups_path
        end
      end
    end
  end

  def edit
    @favorite_group = FavoriteGroup.find(params[:id])
    check_privilege(@favorite_group)
    respond_with(@favorite_group)
  end

  def update
    @favorite_group = FavoriteGroup.find(params[:id])
    check_privilege(@favorite_group)
    @favorite_group.update_attributes(params[:favorite_group])
    unless @favorite_group.errors.any?
      flash[:notice] = "Favorite group updated"
    end
    respond_with(@favorite_group)
  end

  def destroy
    @favorite_group = FavoriteGroup.find(params[:id])
    check_privilege(@favorite_group)
    @favorite_group.destroy
    flash[:notice] = "Favorite group deleted"
    redirect_to favorite_groups_path
  end

  def add_post
    @favorite_group = FavoriteGroup.find(params[:id])
    check_privilege(@favorite_group)
    @post = Post.find(params[:post_id])
    @favorite_group.add!(@post)
  end

private
  def check_privilege(favgroup)
    raise User::PrivilegeError unless favgroup.editable_by?(CurrentUser.user)
  end
end
