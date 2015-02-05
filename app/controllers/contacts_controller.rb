class ContactsController < ApplicationController

  respond_to :html

  # Before filters -----------------------------------------------------
  before_filter :authenticate_user!

  before_action :set_manufacturer

  #
  # CANCAN AUTHORIZATION -----------------------------------------------
  # This helper assumes that the instance variable @group is loaded
  # or checks Class permissions
  #
  authorize_resource

  ######################################################################
  # GET    /admin/manufacturers/:manufacturer_id/contacts/new(.:format)
  #
  # The new method will create a new contact
  ######################################################################
  def new
  end

  ######################################################################
  # GET /admin/manufacturers/:manufacturer_id/contacts/:id(.:format)
  #
  # The edit method will update a manufacturer contact.
  ######################################################################
  def edit
    @contact = @contacts.find(params[:id])
  end

  def index
  end

  ######################################################################
  # POST   /admin/manufacturers/:manufacturer_id/contacts(.:format)
  #
  # The create method will create a new manufacturer contact.
  ######################################################################
  def create
    @new_contact = @manufacturer.contacts.create!(contact_params)
    if @manufacturer.save
        redirect_to @manufacturer, :notice => "Contact was successfully created."
    else
        @verrors = @contact.errors.full_messages
        redirect_to @manufacturer, :notice => "Contact was not successfully created."
    end
  end

  ######################################################################
  # PUT or PATCH  /admin/manufacturers/:manufacturer_id/contacts/:id(.:format)
  #
  # The update method will update a manufacturer contact.
  ######################################################################
  def update

    @update_contact = @contacts.find(params[:id])

    if @update_contact.present?
      if @update_contact.update_attributes(contact_params)
        redirect_to @manufacturer, :notice => "Contact was successfully updated."
      else
        render  :edit
      end
    else
      flash[:alert] = "We could not find the contact."
      redirect_to @manufacturer
    end
  end
  ######################################################################
  # DELETE /admin/manufacturer/:manufacturer_id/contacts/:id(.:format)
  #
  # The destroy method will destroy the contact record associated with
  # the manufacturer object.
  ######################################################################
  def destroy
      @remove_contact = @contacts.find(params[:id])

      if @remove_contact.present?
        begin
          @remove_contact.destroy
          redirect_to @manufacturer, :notice => "Contact was successfully deleted."
        rescue Exception => contact_error
          flash[:alert] = "Error deleting contact - #{contact_error.message}"
          redirect_to @manufacturer
        end
      else
        flash[:alert] = "Could not find contact to delete."
        redirect_to @manufacturer
      end

  end
# PRIVATE INSTANCE METHODS =----------------------------------------
  private

  ####################################################################
  # Use callbacks to share common setup or constraints between actions.
  # We do the following actions:
  # * Try to lookup the resource
  # * Then assign a global variable to access the embedded object
  ####################################################################
  def set_manufacturer
    @manufacturer = Manufacturer.find(params[:manufacturer_id])

    authorize! :update, @manufacturer

    if @manufacturer.contacts.present?
      @contacts = @manufacturer.contacts
    else
      @contacts = nil
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
