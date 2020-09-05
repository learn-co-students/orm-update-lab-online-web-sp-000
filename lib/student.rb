require_relative "../config/environment.rb"

class Student
  
  attr_accessor :name, :grade
  attr_reader :id
  
  def initialize(name,grade,id=nil)
    @name = name
    @grade = grade
    @id = id
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE students(
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade INT
    );
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql_drop = <<-SQL
    DROP TABLE students
    SQL
    DB[:conn].execute(sql_drop)
  end

  def save
    if self.id
      self.update
    else 
      sql_save = <<-SQL
    INSERT INTO students(name,grade)
    VALUES (?,?)
    SQL
    DB[:conn].execute(sql_save,self.name,self.grade)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def self.create(name,grade)
    student = Student.new(name,grade)
    student.save
    student
  end

  def update
    sql_update = <<-SQL
      UPDATE students
      SET name = ?, grade = ?
      WHERE id = ?
    SQL
    DB[:conn].execute(sql_update,self.name,self.grade,self.id)
  end

  

  def self.new_from_db(row)
    student = Student.new(name = row[1], grade = row[2])
    student.save
    student
  end

  def self.find_by_name(name)
    sql_find_name = <<-SQL
      SELECT * FROM students
      WHERE name = ?
      LIMIT 1
      SQL
    DB[:conn].execute(sql_find_name,name).collect {|student| self.new_from_db(student)}.first
  end
  
  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
end
