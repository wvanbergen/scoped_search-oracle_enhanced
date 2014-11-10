require "scoped_search"
require "scoped_search/oracle_enhanced/version"

module ScopedSearch

  # This module adds an OracleEnhanced adapter to improve the search results on Oracle databases.
  # Simply make sure it is loaded by requiring in when you application loads.
  #
  #    require "scoped_search/oracle_enhanced
  #
  module OracleEnhanced
  end

  class QueryBuilder

    # The Oracle adapter also requires some tweaks to make the case insensitive LIKE work.
    class OracleEnhancedAdapter < ScopedSearch::QueryBuilder

      def sql_test(field, operator, value, lhs, &block) # :yields: finder_option_type, value
        if field.key_field
          yield(:parameter, lhs.sub(/^.*\./,''))
        end
        if field.textual? && [:like, :unlike].include?(operator)
          yield(:parameter, (value !~ /^\%|\*/ && value !~ /\%|\*$/) ? "%#{value}%" : value.to_s.tr_s('%*', '%'))
          return "LOWER(#{field.to_sql(operator, &block)}) #{self.sql_operator(operator, field)} LOWER(?)"
        elsif field.temporal?
          return datetime_test(field, operator, value, &block)
        else
          yield(:parameter, value)
          return "#{field.to_sql(operator, &block)} #{self.sql_operator(operator, field)} ?"
        end
      end
    end
  end
end
