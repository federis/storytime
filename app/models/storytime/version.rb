module Storytime
  class Version < ActiveRecord::Base
    include Storytime::ScopedToSite
    belongs_to :user, class_name: Storytime.user_class.to_s
    belongs_to :versionable, polymorphic: true
  end
end
