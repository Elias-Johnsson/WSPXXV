require 'sinatra'
require 'slim'
require 'sqlite3'
require 'sinatra/reloader'
require 'bcrypt'
require_relative 'model.rb'


get('/trava') do
  db = db()
  slim(:start)
end

get('/login') do
  db = db()
  slim(:login)
end

post('/login') do
  
end

get('/signin') do
  slim(:signin)
end