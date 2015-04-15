#######################################################################
# This decorator class wraps view oriented methods around the Organization
# model. It uses the Draper decorator gem to help with this capability.
#######################################################################
class OrganizationDecorator < ApplicationDecorator # Draper::Decorator
  delegate_all

  #####################################################################
  # Returns an array of owner choices to be used with the select
  # view helper. It will exclude the current Organization owner, but
  # include a "no change" option.
  #####################################################################
  def owner_choices
    choices = [["No change", nil]]
    object.users.each do |u|
      choices << ["#{u.email} - #{u.first_name} #{u.last_name}", u.id] unless
        (u.id == object.owner.id) || (u.owns)
    end
    choices
  end

end

