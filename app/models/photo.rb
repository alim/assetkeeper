##########################################################################
# The Photo class is responsible for handling uploaded photos and storing
# them on Amazon S3. It also auto-scales the photos to three additional
# sizes beyond the original.
##########################################################################
class Photo
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip

  # Scope definitions for organizational based queries and User concerns
  include Organizational
  include UserCreatable

  # Add call to strip leading and trailing white spaces from all attributes
  strip_attributes  # See strip_attributes for more information

  ## ATTRIBUTES -------------------------------------------------------

  field :name, type: String
  field :description, type: String
  field :lat, type: String
  field :long, type: String

  has_mongoid_attached_file :image,
    path: ':image/:id/:style.:extension',
    :styles => {
      :small    => ['100x100#',   :jpg],
      :medium   => ['250x250',    :jpg],
      :large    => ['600x600>',   :jpg]
    }

  ## RELATIONSHIPS -----------------------------------------------------

  belongs_to :asset_item
  belongs_to :user
  belongs_to :organization

  ## VALIDATIONS -------------------------------------------------------

  validates_attachment_content_type :image,
    content_type: ["image/jpg", "image/jpeg", "image/png", "image/gif"]
end
