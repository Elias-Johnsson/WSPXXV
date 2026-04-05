require 'sinatra'
require 'slim'
require 'sqlite3'
require 'sinatra/reloader'
require 'bcrypt'
also_reload 'model'
enable :sessions
require_relative 'model.rb'

get('/trava') do
  slim(:start)
end

post('/trava/delete_user') do
  user_id = session[:user_id]
  delete_user(user_id)
  redirect('/trava')
end

get('/error') do
  @error_message = session[:error_mes]
  slim(:error)
end
get('/trava/new') do
  @group_names = select_id_name("groups")
  slim(:new)
end
post('/trava/new') do
  uid = session[:user_id]
  title = params["new_title"]
  description = params["new_desc"]
  @group_names = select_id_name("groups")
  group_id = params["group_id"]
  create_post(title,description,group_id,uid)
  redirect("/trava/index")
end
post("/trava/logout")do
  session.clear
  redirect("/trava")
end
get('/trava/index') do
  if session[:user_id].nil?
    redirect('/trava')
  end
  id = session[:user_id]
  @items = select_posts_users_groups(id)
  @group_names =  select_group_name(id)
  slim(:index)
end
get('/login') do
  slim(:login)
end
post('/trava/:id/delete') do
  id = params[:id].to_i
  posts = select_post(id)
  if posts["user_id"] == session[:user_id].to_i || admin_in_group?(posts["group_id"])
    id = params[:id].to_i
    delete_post(id)
  end
  redirect("/trava/index")
end
get('/trava/:id/edit') do
  @id = params[:id].to_i
  @group_names = select_id_name("groups")
  slim(:edit)
end

get('/trava/new_group') do
  slim(:new_group)
end

post('/trava/new_group') do
  group_name = params["group_name"]
  create_group(group_name)
  group_id = select_group_id(group_name)
  id = session[:user_id]
  role = "admin"
  admin_join_group(id,group_id,role)
  redirect("/trava/index")
end

post('/trava/join_new')do
  id = session[:user_id]
  group_id = params["group_id"].to_i
  role = "Standard"
  join_group(id,group_id,role)
  redirect("/trava/index")
end

post('/trava/:id/update') do
  id = params[:id].to_i
  new_titel = params["new_titel"]
  new_desc = params["new_desc"]
  new_group = params["group_id"]
  posts = select_post(id)
  if posts["user_id"].to_i == session[:user_id].to_i || admin_in_group?(posts["group_id"])
    update_post(new_titel,new_desc,new_group,id)
  end
  redirect('/trava/index')
end

post('/login') do
  user = params["username"]
  pwd = params["password"]
  result = select_pwd_id(user) 
  if result.empty?
      session[:error_mes] = "No such user"
      redirect('/error')
    end
  fails = select_fails(user)
  attempts = fails["failed_attempts"].to_i
  failed_at = fails["last_failed_at"]
  login_state = fails["login_state"]
  if login_state == 1
    if attempts == 5
      time_out_user(user)
    end
    used_id = result.first["id"]
    pwd_digest = result.first["pwd_digest"]
    if decrypt(pwd_digest) == pwd
      update_fails(0,"",user)
      time_in_user(user)
      session[:user_id] = used_id
      redirect('/trava/index')
    else
      session[:error_mes] = "Wrong password"
      attempts += 1
      failed_at = Time.now.to_s
      update_fails(attempts,failed_at,user)
      redirect('/error')
    end
  else
    target_Time = Time.parse(failed_at.to_s) + (5*60)
    if Time.now > target_Time
      login_state = 1
      update_fails(4,"",user)
      time_in_user(user)
      redirect('/login')
    end
    session[:error_mes] = "To many failed attempts, User is timed out till #{target_Time}"
    redirect("/error")
  end
end
get('/signin') do
  @group_names = select_id_name("groups")
  slim(:signin)
end
post('/signin') do
  user = params["username"]
  pwd = params["password"]
  group_index = params["beginner_g"].to_i
  pwd_confirm = params["pwd_confirm"]
  result = select_id(user)
  if result.empty?
    if pwd == pwd_confirm
      pwd_digest = crypt(pwd)
      create_user(user,pwd_digest)
      user_id = select_user_id(user)
      join_group(user_id,group_index,"Standard")
      session[:user_id] = user_id
      redirect("/trava/index")  
    else
      session[:error_mes] = "Passwords do not match"
      redirect('/error')
    end
  end
end