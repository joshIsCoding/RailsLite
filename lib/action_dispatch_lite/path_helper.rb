module ActionDispatchLite
  class PathHelper
    PATH_SUFFIXES = %w[ edit new ]

    attr_reader :route, :path, :rest_type

    def initialize( route )
      @route = route
      @path = stringify_path( route.pattern )
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
      path.chomp( '/new' ).chomp( '/edit' )
             .scan( /\/(\w+)/ )
             .flatten
    end

    private

    def stringify_path( path )
      if path.is_a?( String )
        path
      else
        path.inspect
               .chomp( '$/' )
               .delete_prefix( '/^' )
               .gsub( '\\/', '/' )
      end
    end

    def infer_rest_type
      if path.end_with?( '/edit' )
        :edit
      elsif path.end_with?( "/new" )
        :new
      elsif path.end_with?( "/:id" )
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