require 'sqlite3'

def db
  return @db if @db
  @db = SQLite3::Database.new("db/workouts.db")
  @db.results_as_hash = true
  @db.execute("PRAGMA foreign_keys = ON")
  return @db
end

def select_id_name(table)
  return db.execute("SELECT id, name FROM #{table}")
end

def create_post(title,description,group_id,uid)
  db.execute("INSERT INTO posts (title,description,group_id,user_id) VALUES (?,?,?,?)",[title,description,group_id,uid])
end

def select_posts_users_groups(id)
  sql = "SELECT DISTINCT posts.*, groups.name, users.name AS group_name FROM posts JOIN memberships ON posts.group_id = memberships.group_id JOIN groups ON posts.group_id = groups.id JOIN users ON posts.user_id = users.id WHERE memberships.user_id = ?"
  return db.execute(sql,id)
end

def delete_user(id)
  db.execute("DELETE FROM users WHERE id=?", id)
end

def select_user_id(user)
  db.execute("SELECT id FROM users WHERE name=?",user).first["id"]
end

def select_group_id(group_name) 
  return db.execute("SELECT id FROM groups WHERE name=?",group_name).first["id"]
end

def create_user(user,pwd_digest)
  db.execute("INSERT INTO users(name,pwd_digest,failed_attempts,last_failed_at,login_state) VALUES(?,?,?,?,?)",[user,pwd_digest,0,"",1])
end

def select_post(id)
  return db.execute("SELECT * FROM posts WHERE id=?",id).first
end

def select_userid_id(id)
  return db.execute("SELECT user_id FROM posts WHERE id=?",id).first["user_id"].to_i
end

def update_fails(attempt,failed_at,username)
  db.execute("UPDATE users SET failed_attempts=?, last_failed_at=? WHERE name=?",[attempt,failed_at,username])
end

def select_fails(username)
  arr = db.execute("SELECT failed_attempts, last_failed_at, login_state FROM users WHERE name=?", username).first
  return arr
end

def select_id(user)
  return db.execute("SELECT id FROM users WHERE name=?",user)
end

def time_in_user(username)
  db.execute("UPDATE users SET login_state=? WHERE name=?",[1,username])
end

def time_out_user(username)
  db.execute("UPDATE users SET login_state=? WHERE name=?",[0,username])
end

def select_pwd_id(user)
  return db.execute("SELECT id, pwd_digest FROM users WHERE name=?",user)
end

def update_post(new_titel,new_desc,new_group,id)
  db.execute("UPDATE posts SET title=?,description=?,group_id=? WHERE id=?",[new_titel,new_desc,new_group,id])
end

def join_group(id,group_id,role)
  db.execute("INSERT INTO memberships (user_id,group_id,role) VALUES(?,?,?)", [id,group_id,role])
end

def admin_join_group(id,group_id,role)
  db.execute("INSERT INTO memberships (user_id,group_id,role) VALUES(?,?,?)", [id,group_id,role])
end

def create_group(group_name)
  db.execute("INSERT INTO groups (name) VALUES (?)", [group_name])
end

def delete_post(id)
  db.execute("DELETE FROM posts WHERE id=?",id)
end

def decrypt(pwd_digest)
  return BCrypt::Password.new(pwd_digest)
end

def crypt(pwd)
  return BCrypt::Password.create(pwd)
end

def select_group_name(id)
  return db.execute("SELECT name FROM groups WHERE id NOT IN (SELECT group_id FROM memberships WHERE user_id=?)", id)
end

def admin_in_group?(group_id)
    result = db.execute("SELECT role FROM memberships WHERE user_id = ? AND group_id = ?", [session[:user_id], group_id])
    result.first && result.first["role"] == "admin"
end