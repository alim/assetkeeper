########################################################################
# The AssetsController class is responsible for managing AssetItems
# associated with a user and their organization. The user must be
# authenticated.
########################################################################
class AssetItemsController < ApplicationController
  respond_to :html
  decorates_assigned :asset_item

  ## CALL BACKS --------------------------------------------------------
  before_filter :authenticate_user!

  before_action :set_asset_item, only: [:show, :edit, :update, :destroy]
  before_action :manufacturer_decorate, only: [:new, :edit, :update, :show, :index]

  # CANCAN AUTHORIZATION -----------------------------------------------
  # This helper assumes that the instance variable @group is loaded
  # or checks Class permissions
  authorize_resource

  ######################################################################
  # GET /assets
  # GET /assets.json
  #
  # The index method displays the current users list of assets. If
  # the signed in user is a User::SERVICE_ADMIN, then all assets are
  # listed.
  ######################################################################
  def index
    # Get page number
		page = params[:page].nil? ? 1 : params[:page]

    if current_user.role == User::SERVICE_ADMIN
      @asset_items = AssetItemDecorator.decorate_collection(
        AssetItem.all.asc(:name).paginate(page: page, per_page: PAGE_COUNT))
    else
      @asset_items = AssetItemDecorator.decorate_collection(AssetItem.in_organization(
        current_user).asc(:name).paginate(page: page,  per_page: PAGE_COUNT))
    end

  end

  ######################################################################
  # GET /assets/1
  # GET /assets/1.json
  #
  # The show method will show the asset record. The corresponding
  # view will show the owner name and list of user group names
  # associated with the asset.
  ######################################################################
  def show
  end

  ######################################################################
  # GET /assets/new
  #
  # The new method will show the user a new asset form. It will also
  # lookup any groups that the user may have to see, if they want to
  # grant access to those groups to the user.
  ######################################################################
  def new
    @asset_item = AssetItem.new
  end

  ######################################################################
  # GET /assets/1/edit
  #
  # The standard edit method will display the edit form and include the
  # ability to select groups that will be given access to the asset.
  ######################################################################
  def edit
  end

  ######################################################################
  # POST /assets
  #
  # The create method will create a new asset and relate any selected
  # groups that the user selected.
  ######################################################################
  def create
    @asset_item = AssetItem.create_with_user(asset_params, current_user)

    if @asset_item.save
      @asset_item.relate_to_organization
      redirect_to @asset_item, notice: 'Asset was successfully created.'
    else
      set_errors_render(@asset_item, :new)
    end
  end

  ######################################################################
  # PATCH/PUT /assets/1
  # PATCH/PUT /assets/1.json
  #
  # The update will update the AssetItem model object including any
  # changes to the organization associated with the current user.
  ######################################################################
  def update
    if @asset_item.update_attributes(asset_params)
      @asset_item.relate_to_organization
      redirect_to @asset_item, notice: 'Asset was successfully updated.'
    else
      set_errors_render(@asset_item, :edit)
    end
  end

  ######################################################################
  # DELETE /assets/1
  # DELETE /assets/1.json
  #
  # The destroy asset method will delete the asset, but does not
  # destroy the related groups that were given access to the asset.
  ######################################################################
  def destroy
    asset_name = @asset_item.name
    @asset_item.destroy
    redirect_to asset_items_path, notice: "Asset #{asset_name} was successfully deleted."
  end

  ## PRIVATE INSTANCE METHODS ------------------------------------------

  private

  ######################################################################
  # Use callbacks to share common setup or constraints between actions.
  ######################################################################
  def set_asset_item
    @asset_item = AssetItem.find(params[:id])
  end

  ######################################################################
  # Never trust parameters from the scary internet, only allow the
  # white list through.
  ######################################################################
  def asset_params
    permitted_params = params.require(:asset_item).permit(:name, :description, :location,
      :latitude, :longitude, :material, :date_installed, :condition,
      :failure_probability, :failure_consequence, :status, :manufacturer_index)

    # Parse the mm/dd/yyyy formatted date
    permitted_params[:date_installed] =  DateTime.strptime(permitted_params[:date_installed],
     "%m/%d/%Y").to_s if permitted_params[:date_installed]

    permitted_params
  end

  ######################################################################
  # Use callbacks to ensure a decorated manufacturer is created.
  ######################################################################
  def manufacturer_decorate
    @manu = ManufacturerDecorator.new(Manufacturer.all)
  end

end
