module ActionDispatchLite
  module PathUtilities
    PATH_SUFFIXES = %w[ edit new ]

    def static_segments( pattern )
      pattern = pattern.is_a?( String ) ? pattern : pattern.inspect
      PATH_SUFFIXES.reduce( pattern ) { |pattern,suffix| pattern.chomp( "/#{suffix}" ) }
                   .scan( /\/(\w+)/ )
                   .flatten
    end
  end
end