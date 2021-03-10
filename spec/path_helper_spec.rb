require 'router'
require 'byebug'
require './lib/action_dispatch_lite/path_helper'

describe ActionDispatchLite::PathHelper do
  PATHS = { edit: '/edit', new: '/new', id: '/:id' }

  subject( :path_helper ) { described_class.new( route )}

  let( :route ) { Route.new( Regexp.new( path ), :get, 'CakeOfTheDay', :wow ) }
  
  describe '#rest_type' do

    PATHS.each do |sym, suffix|

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

  describe '#method_name' do

    context 'when the path pertains to a singular resource' do
      
      it 'attempts to singularise the resources plural, when appropriate for the path type' do
        { 'cats' => 'cat', 'cities' => 'city', 'equipment' => 'equipment' }.each do |pl, si|
          route = Route.new( Regexp.new( "^/#{pl}/:id$" ), :get, 'Test', :show )
          expect( described_class.new( route ).method_name )
          .to start_with( "#{si}_" )
        end
      end
    end

    PATHS.each do |sym, path_end|
      next if sym == :id

      context "when the path ends with '#{path_end}'" do
        let( :path ) { "^/cakes#{path_end}$" }

        it "returns a name in the form of #{sym}_resource_path" do
          expect( path_helper.method_name ).to start_with( sym.to_s )
        end
      end
    end

    context "when the path ends with '/:id'" do
      let( :path ) { "^/cakes/:id$" }

      it 'returns the the singularized resource as resource_path' do
        expect( path_helper.method_name ).to eq 'cake_path'
      end
    end

    context 'when the path ends with the pluralised resource' do
      let( :path ) { '^/cakes$' }

      it 'returns the pluralised resource as resources_path' do
        expect( path_helper.method_name ).to eq 'cakes_path'
      end
    end
  end

  describe '#static_segments' do
    let( :path ) { '^/users$' }

    it 'returns the static segment of a simple route path as an array of substrings' do
      expect( path_helper.static_segments ).to eq( [ 'users' ] )
    end
  end
end