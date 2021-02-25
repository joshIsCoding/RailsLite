module ActionControllerLite

  # My implementation of strong params
  class Parameters

    def initialize( param_hash )
      @params = keys_to_sym( param_hash )
      @permitted = class.permit_all_parameters
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

    private

    def keys_to_sym( hash )
      sym_hash = {}
      hash.each do |k,v|
        sym_hash[k.to_sym] = v.is_a?( Hash ) ? keys_to_sym( v ) : v
      end  
      sym_hash
    end 



  end
end