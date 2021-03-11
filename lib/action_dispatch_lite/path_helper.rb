module ActionDispatchLite
  class PathHelper
    PATH_SUFFIXES = %w[ edit new ]

    attr_reader :route, :pattern, :rest_type

    def initialize( route )
      @route = route
      @pattern = stringify_pattern( route.pattern )
      @rest_type = infer_rest_type
    end

    def method_name
      name = case rest_type
             when :edit, :new
               [rest_type] + static_segments[0..-2] + [singularize( static_segments.last )]
             when :resource
               static_segments[0..-2] << singularize( static_segments.last )
             else
               static_segments
             end
      "#{name.join( '_' )}_path"
    end

    def static_segments
      pattern.chomp( '/new' ).chomp( '/edit' )
             .scan( /\/(\w+)/ )
             .flatten
    end

    private

    def stringify_pattern( pattern )
      if pattern.is_a?( String )
        pattern
      else
        pattern.inspect
               .chomp( '$/' )
               .delete_prefix( '/^' )
               .gsub( '\\/', '/' )
      end
    end

    def infer_rest_type
      if pattern.end_with?( '/edit' )
        :edit
      elsif pattern.end_with?( "/new" )
        :new
      elsif pattern.end_with?( "/:id" )
        :resource
      else
        :resources
      end
    end

    def singularize( plural )
      if plural.end_with?( 'ies' )
        plural.chomp( 'ies' ) + 'y'
      elsif plural.end_with?( 's' )
        plural.chomp( 's' )
      else
        plural
      end
    end
  end
end