require 'sqlite3'

db = SQLite3::Database.new("databas.db")


def seed!(db)
  puts "Using db file: db/todos.db"
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
              duration TEXT NOT NULL)')
  db.execute('CREATE TABLE groups(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              members_id INTEGER)')
end

def populate_tables(db)
  db.execute('INSERT INTO users (id,name,pwd_digest) VALUES (1,"Admin", "benis")')
  db.execute('INSERT INTO posts (id, title, desc,group_id,duration) VALUES (1,"BENIS", "En rödgran",1,"20 minuter")')
  db.execute('INSERT INTO groups (id,name, members_id) VALUES (1,"Pynta gran", 1)')
end


seed!(db)





