class Movie < ActiveRecord::Base
    
    # getting distinct ratings and sorting the list
    def self.available_ratings_options
        pluck('DISTINCT rating').sort!
    end

end
