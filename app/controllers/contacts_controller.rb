class ContactsController < ApplicationController

  respond_to :html

  # Before filters -----------------------------------------------------
  before_filter :authenticate_user!

  before_action :set_manufacturer

  # CANCAN AUTHORIZATION -----------------------------------------------
  # This helper assumes that the instance variable @group is loaded
  # or checks Class permissions
  authorize_resource

  #def new
   # @manufacturer.contacts = Contact.new
   # @manufacturer.reload
  #end

  def create
    @contact = @manufacturer.contacts.create!(contact_params)
    @contact.save
    @manufacturer.reload
    redirect_to @manufacturer, :notice => "Contact created"
  end

# PRIVATE INSTANCE METHODS =----------------------------------------
  private

  ####################################################################
  # Use callbacks to share common setup or constraints between actions.
  # We do the following actions:
  # * Try to lookup the resource
  # * Catch the error if not found and redirect with error message
  ####################################################################
  def set_manufacturer
    @manufacturer = Manufacturer.find(params[:manufacturer_id])

    authorize! :update, @manufacturer

    if @manufacturer.contacts.present?
      @contact = @manufacturer.contacts
    else
      @contact = nil
    end
  end
  ######################################################################
  # Never trust parameters from the scary internet, only allow the
  # white list through.
  ######################################################################

    def contact_params
      params.require(:contact).permit(:name, :email, :website, :phone, :body)
    end
end
