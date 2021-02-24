module ActionControllerLite

  # My implementation of strong params
  class Parameters

    def initialize( param_hash )
      @params = {}
      param_hash.each { |k,v| @params[k.to_sym] = v }
      @pemitted = {}
    end

    def self.permit_all_parameters
      @@permit_all ||= false
    end

    def self.permit_all_parameters=( option )
      unless option.is_a?( TrueClass ) || option.is_a?( FalseClass )
        raise ArgumentError, 'option must be boolean'
      end

      @@permit_all = option
    end


    def []( key )
      @params[key.to_sym]
    end

    def []=( key, value )
      @params[key.to_sym] = value
    end



  end
end