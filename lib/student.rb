require_relative "../config/environment.rb"

class Student

  attr_accessor :name, :grade, :id
  
  def initialize(name, grade, id = nil)
    @name = name
    @grade = grade
    @id = id
  end
  
  def self.create_table
    table = <<-SQL
        CREATE TABLE students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade INTEGER
        )
      SQL
    
    DB[:conn].execute(table)
  end
  
  def self.drop_table
    drop = <<-SQL 
        DROP TABLE students
      SQL
  
    DB[:conn].execute(drop)
  end

  def save
    
    if self.id 
      self.update
    else
      insert = <<-SQL
          INSERT INTO students (name, grade)
          VALUES (?, ?)
        SQL
      DB[:conn].execute(insert, self.name, self.grade)
      
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end
  
  def self.create(name, grade)
    student_oi = self.new(name, grade).tap {|student| student.save}
  end
  
  def self.new_from_db(array)
    self.new(array[1], array[2], array[0])
    #create from self.new not self.create
  end
    
  def self.find_by_name(name)
    find = <<-SQL
        SELECT * FROM students
        WHERE name = ?
        LIMIT 1
      SQL
      
    self.new_from_db(DB[:conn].execute(find, name).first) 
    
    #gives an array of arrays => need to choose the right array to pass
  end
    
  def update
    update = <<-SQL
      UPDATE students
      SET name = ?, grade = ?
      WHERE id = ?
    SQL
    
    DB[:conn].execute(update, self.name, self.grade, self.id)  
  end
  
end
