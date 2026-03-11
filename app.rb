require 'sinatra'
require 'slim'
require 'sqlite3'
require 'sinatra/reloader'
require 'bcrypt'
require_relative 'model.rb'

get('/trava') do
  slim(:start)
end

get('/trava/home') do
  db = db()
  id = params["id"].to_i
  @items = db.execute("SELECT * FROM groups WHERE member_id=?",)
  slim(:home)
end
get('/login') do
  db = db()
  slim(:login)
end

post('/login') do
  user = params["username"]
  pwd = params["password"]
  result=db.execute("SELECT id, pwd_digest FROM users WHERE name=?",user)
  if result.empty?
    redirect('/error')
  end
  used_id = result.first["id"]
  pwd_digest = result.first["pwd_digest"]
  if BCrypt::Password.new(pwd_digest) == pwd
    session[:user_id] = used_id
    redirect('/trava/home')
  else
    redirect('/login')
  end
end

get('/signin') do
  slim(:signin)
end

post('/signin') do
  user = params["username"]
  pwd = params["password"]
  pwd_confirm = params["pwd_confirm"]
  result = db.execute("SELECT id FROM users WHERE name=?",user)
  if result.empty?
    if pwd == pwd_confirm
      pwd_digest = BCrypt::Password.create(pwd)
      db.execute("INSERT INTO users(name,pwd_digest) VALUES(?,?)",[user,pwd_digest])
      redirect("/trava/home")  
    else
      redirect('/error')
    end
  else
    redirect('/login')
  end
end