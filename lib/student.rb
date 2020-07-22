require_relative "../config/environment.rb"
require 'pry'

class Student

  attr_accessor :name, :grade, :id
  
  def initialize (name, grade, id = nil)
    @name = name
    @grade = grade
    @id = id
  end
  
  def self.create_table
    
    sql = <<-SQL 
              CREATE TABLE IF NOT EXISTS students (
              id INTEGER PRIMARy KEY,
              name TEXT,
              grade INTEGER
              )
           SQL
           
    DB[:conn].execute(sql)
      
  end
  
  
  def self.drop_table
    sql = "DROP TABLE students"
    DB[:conn].execute(sql)
  end
  
  
  def save
    
    if self.id
      update
    else
      sql = "INSERT INTO students (name, grade) VALUES (?, ?)"
      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end
    
  def update
    sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end
  
  def self.create(name, grade)
    student = Student.new(name, grade)
    student.save
  end
  
  def self.new_from_db(array)
    id = array[0]
    name = array[1]
    grade = array[2]
    Student.new(name, grade, id)
  end
  
  def self.find_by_name(name)
    sql = "SELECT * FROM students WHERE name = ?"
    student_info = DB[:conn].execute(sql, name)[0]
    new_from_db(student_info)
  end

end
