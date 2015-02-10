class AssetDecorator < ApplicationDecorator # Draper::Decorator
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
  # Consequence value translator to string representation for views
  #####################################################################
  def consequence_str
    case object.consequence
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
  # Failure value translator to string representation for views
  #####################################################################
  def failure_str
    case object.failure_probablity
    when 5
      "Immenent"
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
    object.date_installed.strftime("%m/%d/%Y")
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
      "Scheduled for Install"
    when 4
      "Operational"
    when 5
      "Scheduled for Replacement"
    when 6
      "Removed"
    when 7
      "In Maintenance"
    else
      "Unknown"
    end
  end
end
