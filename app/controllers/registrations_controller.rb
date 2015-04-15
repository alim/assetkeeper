#######################################################################
# We override the default Devise::RegistrationsController to handle
# the User (resource) deletion scenario, where the user has a related
# Organization that may have additional members. We do not want to
# delete the user yet, unless ownership of the organization has
# been transferred to another User.
#######################################################################
class RegistrationsController < Devise::RegistrationsController

  def destroy
    begin

      resource.destroy
      Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
      set_flash_message :notice, :destroyed if is_flashing_format?
      yield resource if block_given?
      respond_with_navigational(resource){ redirect_to after_sign_out_path_for(resource_name) }

    rescue Exception => err
      flash[:alert] = "Error deleting your account - #{err.message}"
      redirect_to edit_user_registration_path
    end

  end

end
