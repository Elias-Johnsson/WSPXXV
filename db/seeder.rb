require 'sqlite3'

db = SQLite3::Database.new("workouts.db")


def seed!(db)
  puts "Using db file: db/workouts.db"
  puts "🧹 Dropping old tables..."
  drop_tables(db)
  puts "🧱 Creating tables..."
  create_tables(db)
  puts "🍎 Populating tables..."
  populate_tables(db)
  puts "✅ Done seeding the database!"
end

def drop_tables(db)
  db.execute('DROP TABLE IF EXISTS users')
  db.execute('DROP TABLE IF EXISTS posts')
  db.execute('DROP TABLE IF EXISTS groups')
  db.execute('DROP TABLE IF EXISTS memberships')
end

def create_tables(db)
  db.execute('CREATE TABLE users (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              pwd_digest TEXT NOT NULL)')

  db.execute('CREATE TABLE posts (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT NOT NULL,
              desc TEXT NOT NULL,
              group_id INTEGER,
              user_id INTEGER)')

  db.execute('CREATE TABLE groups (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL)')

  db.execute('CREATE TABLE memberships(
              user_id INTEGER,
              group_id INTEGER)')
end

def populate_tables(db)
  db.execute('INSERT INTO users (id,name,pwd_digest) VALUES (1,"test", "benis")')
  db.execute('INSERT INTO posts (id, title, desc,group_id,user_id) VALUES (1,"BENIS", "En rödgran",1,1)')
  db.execute('INSERT INTO posts (id, title, desc,group_id,user_id) VALUES (2,"LAstian", "SEEBEE",1,2)')
  db.execute('INSERT INTO groups (id,name) VALUES (1,"Pynta gran")')
  db.execute('INSERT INTO memberships (user_id,group_id) VALUES (1,1)')
  db.execute('INSERT INTO memberships (user_id,group_id) VALUES (2,1)')
end


seed!(db)





