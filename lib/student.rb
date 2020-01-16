require_relative "../config/environment.rb"

class Student
  attr_accessor :name, :grade
  attr_reader :id

  def initialize(name, grade, id = nil)
    @name = name 
    @grade = grade
    @id = id
  end 
  
  def self.create_table
    sql = "CREATE TABLE students (
      id INTEGER PRIMARY KEY,
      name TEXT, 
      grade TEXT
      )"
      DB[:conn].execute(sql)
  end 
  
  def self.drop_table
    sql = "DROP TABLE students"
    
    DB[:conn].execute(sql)
  end 
  
  def save 
    if self.id 
      self.update
    else 
      sql = "INSERT INTO students (name, grade) VALUES (?, ?)"
      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end 
  end 
  
  def self.create(name, grade) 
    new_student = self.new(name, grade)
    new_student.save
    new_student
  end 
  
  def update
    sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end 
  
  def self.new_from_db(table_row)
    new_student = self.new(table_row[1], table_row[2], table_row[0])
    new_student
  end 
  
  def self.find_by_name(name) 
    
    sql = "SELECT * FROM students WHERE name = ?"
    
    DB[:conn].execute(sql, name).map {|column_row| self.new_from_db(column_row)}.first
  end 
    

end
