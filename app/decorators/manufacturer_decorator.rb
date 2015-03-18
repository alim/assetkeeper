#######################################################################
# This decorator class wraps view oriented methods around the Asset
# model. It uses the Draper decorator gem to help with this capability.
#######################################################################
class ManufacturerDecorator < ApplicationDecorator # Draper::Decorator
  delegate_all

  #####################################################################
  # Returns an array of manufacturer choices to be used with the select
  # view helper
  #####################################################################

  def manufacturer_choices
     @list_of_manufacturers ||= Array.new

      @manufacturers = Manufacturer.all

      @count = 0

      @manufacturers.each do |p|

        @count = @count + 1

        @list_of_manufacturers.push([p.name, @count])
      end

      @list_of_manufacturers
  end

end
