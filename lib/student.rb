require_relative "../config/environment.rb"

class Student
  attr_accessor :name, :grade 
  attr_reader :id
  
  def initialize(id=nil, name, grade)
    @id = id
    @name = name 
    @grade = grade 
  end 
  
  def self.create_table 
    sql =  <<-SQL 
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY, 
        name TEXT, 
        grade INTEGER
        )
        SQL
				
    DB[:conn].execute(sql) 
  end 
  
  def self.drop_table 
    sql = "DROP TABLE IF EXISTS students"
				
    DB[:conn].execute(sql) 
  end 
  
  def save
    if self.id == nil 
      sql = <<-SQL
        INSERT INTO students (name, grade) 
        VALUES (?, ?)
      SQL
      
      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    else 
      self.update
    end 
  end 
  
  def self.create(name, grade)
    self.new(name, grade).save
  end 
  
  def self.new_from_db(row_array)
    self.new(row_array[0], row_array[1], row_array[2])
  end 
  
  def self.find_by_name(name)
    sql = <<-SQL 
      SELECT * 
      FROM Students 
      WHERE name = ?
      LIMIT 1
    SQL
    
    self.new_from_db(DB[:conn].execute(sql, name).first)
  end 
  
  def update 
    sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

end
