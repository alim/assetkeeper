##########################################################################
# The photos controller will handle requests for the photo model from
# two different contexts. One wil be with in the context of photos
# associated with AssetItem resource and one will be for photo access
# outside the context of a given AssetItem object.
##########################################################################
class PhotosController < ApplicationController
  respond_to :html

  def index
    binding.pry
  end

  def show
  end

  def destroy
  end

  def edit
  end

  def update
  end
end
