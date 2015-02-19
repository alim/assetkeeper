#######################################################################
# This decorator class wraps view oriented methods around the Asset
# model. It uses the Draper decorator gem to help with this capability.
#######################################################################
class AssetItemDecorator < ApplicationDecorator # Draper::Decorator
  delegate_all

  #####################################################################
  # Condition value translator to string representation for views
  #####################################################################
  def condition_str
    case object.condition
    when 5
      "Excellent"
    when 4
      "Very Good"
    when 3
      "Good"
    when 2
      "Poor"
    when 1
      "Very Poor"
    else
      "Unknown"
    end
  end

  #####################################################################
  # Returns an array of condition choices to be used with the select
  # view helper
  #####################################################################
  def condition_choices
    [
      ["Excellent", 5],
      ["Very Good", 4],
      ["Good", 3],
      ["Poor", 2],
      ["Very Poor", 1]
    ]
  end

  #####################################################################
  # Consequence value translator to string representation for views
  #####################################################################
  def consequence_str
    case object.failure_consequence
    when 5
      "Extremely High"
    when 4
      "High"
    when 3
      "Moderate"
    when 2
      "Low"
    when 1
      "Very Low"
    else
      "Unknown"
    end
  end

  #####################################################################
  # Returns an array of condition choices to be used with the select
  # view helper
  #####################################################################
  def consequence_choices
    [
      ["Extremely High", 5],
      ["High", 4],
      ["Moderate", 3],
      ["Low", 2],
      ["Very Low", 1]
    ]
  end

  #####################################################################
  # Failure value translator to string representation for views
  #####################################################################
  def failure_str
    case object.failure_probability
    when 5
      "Imminent"
    when 4
      "Likely"
    when 3
      "Nominal"
    when 2
      "Unlikely"
    when 1
      "Very Unlikely"
    else
      "Unknown"
    end
  end

  #####################################################################
  # Returns an array of failure probability choices to be used with
  # the select view helper
  #####################################################################
  def failure_choices
    [
      ["Imminent", 5],
      ["Likely", 4],
      ["Nominal", 3],
      ["Unlikely", 2],
      ["Very Unlikely", 1]
    ]
  end

  #####################################################################
  # Returns a Google Map URL for the lat/long location of the asset.
  #####################################################################
  def google_map_url
    # "https://www.google.com/maps/place/@#{object.latitude},#{object.longitude},9z"
    "https://www.google.com/maps/place/#{object.latitude},#{object.longitude}/@#{object.latitude},#{object.longitude},15z/"
  end

  #####################################################################
  # Formats the date installed DateTime value to mm/dd/yyyy
  #####################################################################
  def install_date
    if object.date_installed
      object.date_installed.strftime("%m/%d/%Y")
    else
      "Not installed"
    end
  end

  #####################################################################
  # Status value translator to string representation for views
  #####################################################################
  def status_str
    case object.status
    when 1
      "Ordered"
    when 2
      "In Inventory"
    when 3
      "Scheduled Install"
    when 4
      "Operational"
    when 5
      "Scheduled Replacement"
    when 6
      "Removed"
    when 7
      "In Maintenance"
    else
      "Unknown"
    end
  end

  #####################################################################
  # Returns an array of status choices to be used with the select
  # view helper
  #####################################################################
  def status_choices
    [
      ["Ordered", 1],
      ["In Inventory", 2],
      ["Scheduled Install", 3],
      ["Operational", 4],
      ["Scheduled Replacement", 5],
      ["Removed", 6],
      ["In Maintenance", 7]
    ]
  end

end
