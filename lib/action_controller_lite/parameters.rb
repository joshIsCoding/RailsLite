module ActionControllerLite

  # My implementation of strong params
  class Parameters

    def initialize( param_hash )
      @params = keys_to_sym( param_hash )
      @permitted = self.class.permit_all_parameters
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
      val = @params[key.to_sym]

      if val&.is_a?( Hash )
        val = self.class.new( val )
        return val.permitted? ? val.permit! : val
      elsif val
        return val
      end
    end

    def []=( key, value )
      @params[key.to_sym] = value
    end

    def permit( *keys )
      permitted_params = deep_regenerate( @params, *keys )
      self.class.new( permitted_params ).permit!
    end

    def permit!
      @permitted = true
      self
    end

    def permitted?
      @permitted
    end

    private

    def keys_to_sym( hash )
      sym_hash = {}
      hash.each do |k,v|
        sym_hash[k.to_sym] = v.is_a?( Hash ) ? keys_to_sym( v ) : v
      end  
      sym_hash
    end

    def deep_regenerate( hash, *target_keys )
      new_hash = {}
      target_keys.each do |k|
        if k.is_a?( Hash ) # keys can map to arrays of nested keys, eg. permit_me: [ :p2, p3, :p4 ]
          nested_k = k.keys.first
          new_hash[nested_k] = deep_regenerate( hash[nested_k], *k[nested_k] )
        else
          new_hash[k] = hash[k]
        end
      end
      new_hash
    end
  end
end