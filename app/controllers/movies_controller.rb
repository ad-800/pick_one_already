class MoviesController < ApplicationController
  def index
    # Only wanted sample of 5
    # count = Movie.count
    # random_offset = rand(count)
    # Movie.offset(random_offset).first
    @movies = Movie.where(saved: false).sample(5)
    @saved = Movie.where(saved: true)
  end

  def update
    # move movie to saved folder
    # changes db to saved: true
    @movie = Movie.find(params[:id])
    if @movie.saved
      @movie.update(saved: false)
    else
      @movie.update(saved: true)
    end
    redirect_to movies_path
  end
end
