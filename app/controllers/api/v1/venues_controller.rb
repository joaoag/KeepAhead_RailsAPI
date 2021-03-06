class Api::V1::VenuesController < ApplicationController
  
  def index
    render json: Venue.includes(:donations).all.to_json(include: :donations)
  end

  def create
    user_location = params[:location].permit(:lat, :long)
    bounds = make_bounds(user_location)

    venues = Venue.where('lattitude BETWEEN ? AND ?',bounds[:lat_lower], bounds[:lat_upper]).where('longitude BETWEEN ? AND ?', bounds[:long_lower], bounds[:long_upper]).as_json 
    
    venues = venues.each do |venue|
      venue[:distance] = haversineDistanceBetween(user_location, venue)
    end 
    p 'start *****'
    p venues

    venues = venues.sort_by{|venue| venue[:distance]}
    p 'sorted'
    p venues


    render json: venues
  end
  
  ## dont think we need this 
  def show
    venue = Venue.find(params[:id])
    render json: venue
  end

  private

  def make_bounds(user_location)
    long_bound = 0.08 #0.02
    lat_bound = 0.08 #0.03
    user_lat = user_location['lat'].to_f.round(2)
    user_long = user_location['long'].to_f.round(2)


    return {
      lat_upper: (user_lat + lat_bound),
      lat_lower: (user_lat - lat_bound),
      long_upper: (user_long + long_bound),
      long_lower: (user_long - long_bound)
    }
  end

  def to_rad(x)
    x * (Math::PI / 180)
  end

  def haversineDistanceBetween(user, venue)
      lat1 = user[:lat].to_f
      lon1 = user[:long].to_f
      lat2 = venue['lattitude'].to_f
      lon2 = venue['longitude'].to_f
      
      dLat = to_rad(lat2 - lat1);
      dLon = to_rad(lon2 - lon1);
      a = Math.sin(dLat/2) * Math.sin(dLat/2) +
          Math.cos(to_rad(lat1)) * Math.cos(to_rad(lat2)) *
          Math.sin(dLon/2) * Math.sin(dLon/2);
      c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
    return (6371 * c).to_f.round(2) ; 
  end

 
end
