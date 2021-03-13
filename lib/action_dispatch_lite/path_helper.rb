module ActionDispatchLite
  module PathHelper
    PATH_SUFFIXES = %w[ edit new ]

    def method_name( path )
      segments = static_segments( path )
      name = case rest_type( path )
             when :edit, :new
               [rest_type( path )] + segments[0..-2] << singularize( segments.last )
             when :resource
               segments[0..-2] << singularize( segments.last )
             else
               segments
             end
      name.join( '_' )
    end

    def static_segments( path )
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

    def rest_type( path )
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