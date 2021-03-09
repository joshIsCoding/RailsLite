require 'router'
require 'byebug'
require './lib/action_dispatch_lite/path_helper'

describe ActionDispatchLite::PathHelper do
  subject( :path_helper ) { described_class.new( route )}

  let( :route ) { Route.new( Regexp.new('^/users$'), :get, 'CakeOfTheDay', :show ) }
  
  describe '#rest_type' do
    let( :route ) { Route.new( Regexp.new( path ), :get, 'CakeOfTheDay', :wow ) }

    { edit: '/edit', new: '/new', id: '/:id' }.each do |sym, suffix|

      context "when the path ends with '#{suffix}'" do
        let( :path ) { "^/cakes#{suffix}$" }

        it "is set to :#{sym} on init" do
          expect( path_helper.rest_type ).to eq( sym == :id ? :resource : sym )
        end
      end
    end

    context "when the path isn't recognised as an edit, new or resource path" do
      let( :path ) { "^/cakes$" }

      it 'is set to :resources on init' do
        expect( path_helper.rest_type ).to eq( :resources )
      end
    end
  end

  describe '#static_segments' do
    it 'returns the static segment of a simple route path as an array of substrings' do
      expect( path_helper.static_segments ).to eq( [ 'users' ] )
    end
  end
end