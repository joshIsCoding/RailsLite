require 'rack'
require_relative '../lib/controller_base.rb'
require_relative '../lib/router'

# To test out your CSRF protection, go to the new dog form and
# make sure it works! Alter the form_authenticity_token and see that
# your server throws an error. 

class Dog
  attr_reader :name, :owner

  def self.all
    @dogs ||= []
  end

  def initialize(params = {})
    params ||= {}
    @name, @owner = params["name"], params["owner"]
  end

  def errors
    @errors ||= []
  end

  def valid?
    errors << "Owner can't be blank" unless @owner.present?
    errors << "Name can't be blank" unless @name.present?
    
    if errors.any?
      false
    else
      true
    end
  end

  def save
    return false unless valid?

    Dog.all << self
    true
  end

  def inspect
    { name: name, owner: owner }.inspect
  end
end

class DogsController < ControllerBase
  protect_from_forgery

  def create
    @dog = Dog.new( dog_params[:dog] )
    if @dog.save
      flash[:notice] = "Saved dog successfully"
      redirect_to "/dogs"
    else
      flash.now[:errors] = @dog.errors
      render :new
    end
  end

  def index
    @dogs = Dog.all
    render :index
  end

  def new
    @dog = Dog.new
    render :new
  end

  private

  def dog_params
    params.permit( dog: [ :name, :owner ])
  end
end

router = Router.new
router.draw do
  get Regexp.new("^/dogs$"), DogsController, :index
  get Regexp.new("^/dogs/new$"), DogsController, :new
  get Regexp.new("^/dogs/(?<id>\\d+)$"), DogsController, :show
  post Regexp.new("^/dogs$"), DogsController, :create
end

app = Proc.new do |env|
  req = Rack::Request.new(env)
  res = Rack::Response.new
  router.run(req, res)
  res.finish
end

Rack::Server.start(
 app: app,
 Port: 3000
)
