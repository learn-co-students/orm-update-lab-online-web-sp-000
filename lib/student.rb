require_relative "../config/environment.rb"

class Student

  attr_accessor :name, :grade
  attr_reader :id
  
  def initialize (id = nil, name, grade)
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
    sql = "DROP TABLE IF EXISTS students"
    
    DB[:conn].execute(sql)
  end

  def update
    sql = <<-SQL
      UPDATE students
      SET name=?, grade=?
      WHERE id = ?
    SQL
    
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end
  
  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO students (name, grade)
        VALUES (?, ?)
      SQL
    
      DB[:conn].execute(sql, self.name, self.grade)
      @id  = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end
  
  def self.create (name, grade)
    student = self.new(name, grade)
    student.save
    student
  end
  
  def self.new_from_db (student_data)
    self.new(student_data[0], student_data[1], student_data[2])
  end
  
  def self.find_by_name (name)
    sql = <<-SQL
      SELECT * FROM students 
      WHERE name = ?
    SQL
    
    student = DB[:conn].execute(sql, name)[0]
    self.new_from_db(student)
  end

end
