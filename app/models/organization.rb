########################################################################
# The Organization class allows us to authorize access to resources
# related to an organization class. Users belong to an organization and
# other service resources also belong to an organization. Access is
# granted to resources that share the same organizational relationship.
#
# The Organization class is owned by a user, which is identified as
# an Orgnization administrator. The owner has the rights to add users
# to the organization.
########################################################################
class Organization
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :description, type: String

  # attr_accessor :members

  ## RELATIONSHIPS -----------------------------------------------------

  has_many :users
  belongs_to :owner, class_name: 'User', inverse_of: :owns

  # Sample primary resource relation. We are using a resource that
  # represents a Project in our service. We also set a class constant
  # to the name of the class to which the groups will be given access

  has_many :projects
  has_many :asset_items
  has_many :photos

  delegate :email, to: :owner, prefix: true

  ## VALIDATIONS -------------------------------------------------------

  validate :members_list
  validates_presence_of :name
  validates_presence_of :description
  validates_presence_of :owner
  validates_uniqueness_of :owner

  ## PUBLIC CLASS METHODS ----------------------------------------------

  #####################################################################
  # Create a new project and relate the user record to it.
  #####################################################################
  def self.create_with_owner(org_params, owner)
    org = Organization.new(org_params)
    org.owner = owner
    owner.organization = org
    org
  end

  ## PUBLIC INSTANCE METHODS -------------------------------------------

  ######################################################################
  # Creates an instance variable to hold the UserEmailList. The members
  # list is passed as a parameter during the creation or editing of an
  # Organization records.
  ######################################################################
  def members=(email_list)
    @org_email_list = UserEmailList.new(email_list)
  end

  ######################################################################
  # Returns the list of member email addresses
  ######################################################################
  def members
    @org_email_list && @org_email_list.email_list
  end

  ######################################################################
  # Checks each email address and adds a validation error, if an
  # email address is invalid. One error message is added for each invalid
  # email address.
  ######################################################################
  def members_list
    @org_email_list && (errors = @org_email_list.check_list)
    return true unless errors
    errors.each do |error|
      self.errors.add(:members, "invalid email addresses #{error}")
    end
  end

  ######################################################################
  # Creates or looks up a user for each email address. The list of
  # users are then notified of their affiliation to the organization.
  ######################################################################
  def create_notify
    @org_email_list && (users = @org_email_list.create_users)
    return nil unless users

    users.each do |user|
      self.users << user
      OrganizationMailer.member_email(user, self).deliver
    end
  end

  ######################################################################
  # The invite_member method will resend an membership notification
  # to an existing member. If the member has not ever logged into the
  # service the member will be sent a new password.
  #
  # * user - User object to notify
  ######################################################################
  def invite_member(user)
    if user.sign_in_count == 0
      user.password = user.password_confirmation = Devise.friendly_token
        .first(UserEmailList::PASSWORD_LENGTH)

      user.save ? OrganizationMailer.member_email(user, self).deliver : false
    else
      OrganizationMailer.member_email(user, self).deliver
    end
  end

  ######################################################################
  # The remove_member method will remove selected group members
  # The parameter is a list of group members that represents an array,
  # which includes user ID's of the members to disassociate from the
  # group
  ######################################################################
  def remove_members(members)
    return unless members.present?
    members.each do |uid|
      user = User.find(uid)
      users.delete(user)
    end
    reload
  end

  ######################################################################
  # The relate_classes method will relate instances of each class that
  # belongs_to an organization.
  ######################################################################
  def relate_classes
    associated_classes.each do |rclass|
      oids = rclass.where(user_id: owner_id).pluck(:id)
      assignment_method = rclass.to_s.underscore + '_ids='
      send(assignment_method, oids) if oids.present?
    end
  end

  #####################################################################
  # The unrelate_classes method is responsible for disassociating
  # all other classes from the Organization object.
  #####################################################################
  def unrelate_classes
    # Should generate a call like projects.clear
    associated_classes.each do |rclass|
      send(rclass.to_s.pluralize.underscore + '=', nil)
    end
  end

  #####################################################################
  # A utility method to notify organization members and relate
  # associated classes
  #####################################################################
  def notify_and_update_classes
    create_notify
    relate_classes
  end

  #####################################################################
  # The managed_classes method will returns a hash of classes managed
  # by the organization. The hash keys will be the class names, and
  # the hash values will be class instances.
  #####################################################################
  def managed_classes
    classes = {}
    return unless (related_classes = reflect_on_all_associations(:has_many)).present?

    related_classes.each do |rclass|
      class_name = rclass.name.to_s.camelize.singularize.constantize
      records = class_name.where(organization_id: id)
      if class_name != User && records.present?
        classes[class_name.to_s.downcase.to_sym] = records
      end
    end

    classes
  end

  ## PRIVATE INSTANCE METHODS -----------------------------------------

  private

  #####################################################################
  # Returns an array of Class constant names that reflect a list of
  # classes associated to the Organization class. It does not include
  # the User class.
  #####################################################################
  def associated_classes
    classes = []
    reflect_on_all_associations(:has_many).each do |aclass|
      class_name = aclass.name.to_s.camelize.singularize.constantize
      (classes << class_name) unless class_name == User
    end
    classes
  end
end
