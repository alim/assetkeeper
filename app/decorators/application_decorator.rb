##########################################################################
# Base class decorator for controllers that use paginators. It overrides
# the default collection decorator class with one specific for the
# paginator that we are using.
##########################################################################
class ApplicationDecorator < Draper::Decorator
  def self.collection_decorator_class
    PaginatingDecorator
  end
end
