require 'router'
require './lib/action_dispatch_lite/path_helper'

describe ActionDispatchLite::PathHelper do
  subject( :path_helper ) { described_class.new( route )}

  let( :route ) { Route.new( Regexp.new('^/users$'), :get, 'CakeOfTheDay', :show ) }

  describe '#static_segments' do
    it 'returns the static segment of a simple route path as an array of substrings' do
      expect( path_helper.static_segments ).to eq( [ 'users' ] )
    end
  end
end