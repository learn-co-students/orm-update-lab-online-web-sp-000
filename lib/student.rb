require_relative "../config/environment.rb"

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  attr_accessor :name, :grade
  attr_reader :id

  def initialize (name, grade, id = nil)
    @name = name
    @grade = grade
    @id = id
  end

  def self.create_table
    sql = <<-SQL
          CREATE TABLE IF NOT EXISTS students (
          id INTEGER PRIMARY KEY,
          name TEXT,
          grade INTEGER
          )
          SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
          DROP TABLE students
          SQL
    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
          SELECT * from students WHERE id=?
          SQL
    rows = DB[:conn].execute(sql, @id)
    if (rows.count != 0)
      sql = <<-SQL
            UPDATE students SET name=?, grade=? WHERE id=?
            SQL
      DB[:conn].execute(sql, @name, @grade, @id)
    else
      sql = <<-SQL
            INSERT INTO students (name, grade) VALUES (?,?)
            SQL
      DB[:conn].execute(sql, @name, @grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end
def self.create (name, grade)
  student = Student.new(name, grade)
  student.save
end
def self.new_from_db

end

def self.find_by_name(name)
  sql = <<-SQL
        SELECT * from students WHERE name=?
        SQL
  rows = DB[:conn].execute(sql, name)
  student = Student.new_from_db(rows[0])
  return student
end

def self.new_from_db(row)
  student = Student.new(row[1], row[2], row[0])
  return student
end
def update
  sql = <<-SQL
        UPDATE students SET name=?, grade=? WHERE id=?
        SQL
  DB[:conn].execute(sql, @name, @grade, @id)
end
end
