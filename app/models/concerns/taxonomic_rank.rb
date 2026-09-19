module TaxonomicRank
  extend ActiveSupport::Concern

  included do
    scope :search, ->(query) {
      return self.none if query.blank? || query.length < 3

      tsquery = query.split.join(" & ")
      tsquery << ":*" unless tsquery.end_with?(":*")
      rank_sql = ActiveRecord::Base.sanitize_sql_array([ "ts_rank(search_vector, to_tsquery('simple', ?)) DESC", tsquery ])

      where("search_vector @@ to_tsquery('simple', ?)", tsquery)
        .order(Arel.sql(rank_sql))
    }
  end

  class_methods do
    def to_sym
      self.to_s.downcase.to_sym
    end

    def rank_name
      name.demodulize
    end

    def to_plural_sym
      self.to_s.pluralize.downcase.to_sym
    end
  end
end
