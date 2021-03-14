require 'router'
require 'byebug'
require './lib/action_dispatch_lite/path_helper'

describe ActionDispatchLite::PathHelper do
  PATHS = { edit: '/edit', new: '/new', id: '/:id' }

  subject( :route ) { Route.new( Regexp.new( path ), :get, 'CakeOfTheDay', :wow ) }

  describe '#method_name' do

    context 'when the path pertains to a singular resource' do
      
      it 'attempts to singularise the resources plural, when appropriate for the path type' do
        { 'cats' => 'cat', 'cities' => 'city', 'equipment' => 'equipment' }.each do |pl, si|
          route = Route.new( Regexp.new( "^/#{pl}/:id$" ), :get, 'Test', :show )
          expect( route.method_name )
          .to eq( si )
        end
      end
    end

    PATHS.each do |sym, path_end|
      next if sym == :id

      context "when the path ends with '#{path_end}'" do
        let( :path ) { "^/cakes#{path_end}$" }

        it "returns a name in the form of #{sym}_resource" do
          expect( route.method_name ).to start_with( sym.to_s )
        end
      end
    end

    context "when the path ends with '/:id'" do
      let( :path ) { "^/cakes/:id$" }

      it 'returns the the singularized resource name' do
        expect( route.method_name ).to eq 'cake'
      end
    end

    context 'when the path ends with the pluralised resource' do
      let( :path ) { '^/cakes$' }

      it 'returns the pluralised resource name' do
        expect( route.method_name ).to eq 'cakes'
      end
    end
  end

  describe '#path' do
    reg_strings = { 
      '^/account/users$' => '/account/users',
      '^/users/:id$' => '/users/:id',
      '^/chippy_teas/edit$' => '/chippy_teas/edit'
    }

    context 'when the route pattern is a regex' do

      it 'converts regex paths to string url paths on init' do
        reg_strings.each do |regex, path|
          route = Route.new( Regexp.new( regex ), :get, 'CakeOfTheDay', :wow )
          expect( route.path ).to eq( path )
        end
      end
    end

    context 'when the route pattern is a string' do

      it 'does not alter the path string' do
        reg_strings.values.each do |path|
          route = Route.new( path, :get, 'Paths', :x )
          expect( route.path ).to eq( path )
        end
      end
    end
  end

  describe '#static_segments' do
    let( :path ) { '^/users$' }

    it 'returns the static segment of a simple route path as an array of substrings' do
      expect( route.static_segments( route.path ) ).to eq( [ 'users' ] )
    end
  end
end