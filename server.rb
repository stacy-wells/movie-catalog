require 'sinatra'
require 'pg'
require 'pry'

def db_connection
  begin
    connection = PG.connect(dbname: "movies")
    yield(connection)
  ensure
    connection.close
  end
end


get '/actors' do

  actors = ""
  db_connection do |conn|
  results = conn.exec('SELECT name, id FROM actors ORDER BY name;')
  actors = results.to_a
  end

  erb :'actors/index', locals: {actors: actors}
end

get '/actors/:id' do
  id = params[:id]
  ids = ''
  db_connection do |conn|
    ids = conn.exec_params('SELECT movies.title, movies.id, cast_members.character, actors.name
                                FROM movies
                                JOIN cast_members
                                ON (movies.id = cast_members.movie_id)
                                JOIN actors
                                ON (cast_members.actor_id = actors.id)
                                WHERE actors.id = $1',[id]).to_a
  end
  erb :'actors/details', locals: { id: id, ids: ids }
end



get '/movies' do
  movies = ""
  db_connection do |conn|
    movies = conn.exec('SELECT title, movies.id, year, rating, genres.name AS genre, studios.name AS studio
                         FROM movies
                         JOIN genres
                         ON (movies.genre_id = genres.id)
                         JOIN studios
                         ON (movies.studio_id = studios.id)
                         ORDER BY title;').to_a
  end
  erb :'movies/index', locals: {movies: movies}
end

get '/movies/:id' do
  id = params[:id]
  ids = ''
  db_connection do |conn|
    ids = conn.exec_params('SELECT title, movies.id, year, rating, actors.id, actors.name AS actors, character, genres.name AS genre, studios.name AS studio
                            FROM movies
                            JOIN genres
                            ON (movies.genre_id = genres.id)
                            JOIN studios
                            ON (movies.studio_id = studios.id)
                            JOIN cast_members
                            ON (cast_members.movie_id = movies.id)
                            JOIN actors
                            ON (actors.id = cast_members.actor_id)
                            WHERE movies.id = $1', [id]).to_a
  end
  erb :'movies/details', locals: { id: id, ids: ids }
end
