module TaxonomicRank
  extend ActiveSupport::Concern

  class_methods do
    def to_plural_sym
      self.to_s.pluralize.downcase.to_sym
    end
  end
end
