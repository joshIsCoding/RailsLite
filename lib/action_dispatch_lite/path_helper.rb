module ActionDispatchLite
  class PathHelper
    PATH_SUFFIXES = %w[ edit new ]

    attr_reader :route, :pattern

    def initialize( route )
      @route = route
      @pattern = route.pattern
    end

    

    def static_segments
      pattern_str = pattern.is_a?( String ) ? pattern : pattern.inspect
      PATH_SUFFIXES.reduce( pattern_str ) { |pattern_str,suffix| pattern_str.chomp( "/#{suffix}" ) }
                   .scan( /\/(\w+)/ )
                   .flatten
    end
  end
end