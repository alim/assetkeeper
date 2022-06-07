################################################################################
# The ManfacturersController class is responsible for managing manufacturer
# resources associated with the web service. It is the primary resource
# to which other records are related. Being a primary resource allows
# us to manage, authorization for group access to a manufacturer and all its
# related records.
#
# The controller uses an injection model for relating a manufacturer to a
# a group. See lib/group_access.rb for injected methods.
################################################################################

class ManufacturersController < ApplicationController
  respond_to :html

 ## CALL BACKS --------------------------------------------------------
  before_filter :authenticate_user!

  before_action :set_manufacturer, only: [:show, :edit, :update, :destroy]

 # CANCAN AUTHORIZATION -----------------------------------------------
 # This helper assumes that the instance variable @group is loaded
 # or checks Class permissions
 authorize_resource

  #############################################################################
  # GET /manufacturers
  # GET /manufacturers.json
  #
  # The index method displays the current users list of manufacturers. If
  # the signed in user is a User::SERVICE_ADMIN, then all manufacturers are
  # listed.
  #############################################################################

  def index

     # Get page number
                page = params[:page].nil? ? 1 : params[:page]

    #if current_user.role == User::SERVICE_ADMIN
      @manufacturers = Manufacturer.all.paginate(page: page,      per_page: PAGE_COUNT)
    #end
  end

  #########################################################################
  # GET /manufacturers/1
  # GET /manufacturers/1.json
  #
  # The show method will show the manufacturer record. The corresponding
  # view will show the owner name and list of user group names
  # associated with the manufacturer.
  #########################################################################

  def show
  end

  #########################################################################
  # GET /manufacturers/new
  #
  # The new method will show the user a new manufacturers form. It will
  # also lookup any groups that the user may have to see, if they want
  # to grant access to those groups to the user.
  #########################################################################

  def new
    if current_user.role == User::SERVICE_ADMIN
     @manufacturer = Manufacturer.new
    end
  end

  #########################################################################
  # GET /manufacturers/1/edit
  #
  # The standard edit method will display the edit form and include the
  # ability to select groups that will be given access to the
  # manufacturers.
  #########################################################################

  def edit
  end

  #########################################################################
  # POST /manufacturers
  #
  # The create method will create a new manufacturer and relate any
  # selected groups that the user selected.
  #########################################################################

  def create

    @manufacturer = Manufacturer.create_with_user(manufacturer_params, current_user)

    if current_user.role == User::SERVICE_ADMIN
     if @manufacturer.save
      redirect_to @manufacturer, notice: 'Manufacturer was successfully created.'
     else
      set_errors_render(@manufacturer, :new)
    end
   end
  end

  #########################################################################
  # PATCH/PUT /manufacturers/1
  # PATCH/PUT /manufacturers/1.json
  #
  # The update will update the Manufacturer model object including any
  # changes to the organization associated with the current user.
  #########################################################################

  def update

    if current_user.role == User::SERVICE_ADMIN
     if @manufacturer.update_attributes(manufacturer_params)
      redirect_to @manufacturer, notice: 'Manufacturer was successfully updated.'
     else
      set_errors_render(@manufacturer, :edit)
    end
   end
  end

  #########################################################################
  # DELETE /manufacturers/1
  # DELETE /manufacturers/1.json
  #
  # The destroy manufacturer method will delete the manufacturer,
  # but does not destroy the related groups that were given access to
  # the manufacturer.
  #########################################################################

  def destroy
    if current_user.role == User::SERVICE_ADMIN
     @manufacturer.destroy
     redirect_to manufacturers_url, notice: "Manufacturer was successfully deleted."
    end
  end

  ## PRIVATE INSTANCE METHODS ------------------------------------------

  private

  #########################################################################
  # Use callbacks to share common setup or constraints between actions.
  #########################################################################

    def set_manufacturer
      @manufacturer = Manufacturer.find(params[:id])
    end

  #########################################################################
  # Never trust parameters from the scary internet, only allow the
  # white list through.
  #########################################################################

    def manufacturer_params
      params.require(:manufacturer).permit(:name, :address, :website, :main_phone, :main_fax, :tags)
    end
end
