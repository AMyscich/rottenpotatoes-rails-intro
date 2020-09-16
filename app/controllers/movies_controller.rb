class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    
    # getting all movies
    @movies = Movie.all
    
    # getting all ratings
    @all_ratings = Movie.available_ratings_options
    
    # checking if ratings can be applied
    if params[:ratings]
      
      # getting the ratings values from the params
      @ratings = params[:ratings].keys
      
      # maintaining session ratings
      session[:filtered_rating] = @ratings
      
      if session[:sort] and not params[:sort]
        
        # instatiating new hash
        query_hash = Hash.new
        
        # maintaining session fitlered ratings
        query_hash['ratings'] = params[:ratings]
        
        # if allowable sortable sort
        if params[:sort]
          query_hash['sort'] = params[:sort]
        else
          query_hash['sort'] = session[:sort]
        end 
        
        redirect_to movies_path(query_hash)
      end
      
    elsif session[:filtered_rating] # checking for sessions filtered ratings, if applicable
      
      # instatiating new hash
      query_hash = Hash.new
      
      # maintaining session fitlered ratings
      query_hash['ratings'] = Hash[session[:filtered_rating].collect { |item| [item, "1"] } ]

      
      # if allowable sortable sort
      if params[:sort]
        query_hash['sort'] = params[:sort]
      else
        query_hash['sort'] = session[:sort]
      end      
      
      # storing empty to session's filtered ratings
      session[:filtered_rating] = nil
      
      # maining the flash entries
      flash.keep
      
      # redirecting to browser page that issued request
      redirect_to movies_path(query_hash)
    else 
      # getting all ratings
      @ratings = @all_ratings
    end
    
    # getting movies with specified rating
    @movies.where!(rating: @ratings)
    
    # when sorted highlight, change reordering in ascending order
    case params[:sort]
    when 'release_date'
      @release_date_class = "hilite"
      @movies.order!('release_date')
      @release_date_path = "none"
      @title_path = "title"
      session[:sort] = 'release_date'
    when 'title'
      @title_class = "hilite"
      @movies.order!('title')
      @release_date_path = "release_date"
      @title_path = "none"
      session[:sort] = 'title'
    when nil
      @release_date_path = "release_date"
      @title_path = "title"
      session[:sort] = "none"
    end
    
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
