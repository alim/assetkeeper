class ContactsController < ApplicationController

  respond_to :html

  # Before filters -----------------------------------------------------
  before_filter :authenticate_user!

  before_action :set_manufacturer

  # CANCAN AUTHORIZATION -----------------------------------------------
  # This helper assumes that the instance variable @group is loaded
  # or checks Class permissions
  authorize_resource

  def new
    @manufacturer.contacts = Contact.new
    @manufacturer.reload
  end

  def create
    @contact = @manufacturer.contacts.create!(params[:contact])
    redirect_to @manufacturer, :notice => "Comment created"
  end

# PROTECTED INSTANCE METHODS =----------------------------------------
  protected

  ####################################################################
  # Use callbacks to share common setup or constraints between actions.
  # We do the following actions:
  # * Try to lookup the resource
  # * Catch the error if not found and redirect with error message
  ####################################################################
  def set_manufacturer
    @manufacturer = Manufacturer.find(params[:manufacturer_id])

    authorize! :update, @manufacturer

    #if @manufacturer.contacts.present?
      #@contact = @manufacturer.contacts
    #else
      #@contact = nil
    #end
  end
end
