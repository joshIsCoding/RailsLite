module ActionDispatchLite
  class PathHelper
    PATH_SUFFIXES = %w[ edit new ]

    attr_reader :route, :pattern, :rest_type

    def initialize( route )
      @route = route
      @pattern = stringify_pattern( route.pattern )
      @rest_type = infer_rest_type
    end

    def static_segments
      pattern.chomp( '/new' ).chomp( '/edit' )
                   .scan( /\/(\w+)/ )
                   .flatten
    end

    private

    def stringify_pattern( pattern )
      pattern.is_a?( String ) ? pattern : pattern.inspect.chomp( '$/' ).delete_prefix( '/^' )
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
  end
end