require 'sinatra'
require 'slim'
require 'sqlite3'
require 'sinatra/reloader'
require 'bcrypt'
require_relative 'model.rb'
enable :sessions
get('/trava') do
  slim(:start)
end
get('/trava/new') do
  p session
  slim(:new)
end
post('/trava/new') do
  db = db()
  uid = session[:user_id]
  title = params["new_title"]
  desc = params["new_desc"]
  group_id = params["group_id"].to_i
  db.execute("INSERT INTO posts (title,desc,group_id,user_id) VALUES (?,?,?,?)",[title,desc,group_id,uid])
  redirect("/trava/index")
end
get('/trava/index') do
  db = db()
  id = session[:user_id]
  sql = "SELECT posts.*, groups.name AS group_name FROM posts JOIN memberships ON posts.group_id = memberships.group_id JOIN groups ON posts.group_id = groups.id WHERE memberships.user_id = ?"
  @items = db.execute(sql, id)
  slim(:index)
end
get('/login') do
  db = db()
  slim(:login)
end
post('/trava/:id/delete') do
  id = params[:id].to_i
  db.execute("DELETE FROM posts WHERE id=?",id)
  redirect("/trava/index")
end
post('/login') do
  db = db()
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
    redirect('/trava/index')
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
  group_index = params["beginner_g"].to_i
  pwd_confirm = params["pwd_confirm"]
  result = db.execute("SELECT id FROM users WHERE name=?",user)
  if result.empty?
    if pwd == pwd_confirm
      pwd_digest = BCrypt::Password.create(pwd)
      db.execute("INSERT INTO users(name,pwd_digest) VALUES(?,?)",[user,pwd_digest])
      used_id = db.execute("SELECT id FROM users WHERE name=?",user).first["id"]
      db.execute("INSERT INTO memberships(user_id,group_id) VALUES(?,?)",[used_id,group_index])
      session[:user_id] = used_id
      redirect("/trava/index")  
    else
      redirect('/error')
    end
  else
    redirect('/login')
  end
end