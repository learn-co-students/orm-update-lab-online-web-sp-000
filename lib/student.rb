require_relative "../config/environment.rb"

class Student

  attr_accessor :name, :grade, :id
  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  def initialize(name, grade, id=nil)
    @name = name
    @grade = grade 
    @id = id 
  end
  
  def self.create_table
    sql = <<-SQL
      CREATE TABLE students (
        name TEXT, 
        grade TEXT,
        id INTEGER PRIMARY KEY
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
    if(id==nil)
      sql = <<-SQL
        INSERT INTO students (name, grade) 
        VALUES (?, ?)
      SQL
   
      DB[:conn].execute(sql, self.name, self.grade)
   
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    else 
      update 
    end

  end 
  
  def self.create(name, grade)
      out = new(name, grade)
      out.save
      return out
  end 
  
  def self.new_from_db(row)
    out = new(row[1], row[2], row[0])
    return out
  end
    
  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM students WHERE name  = ?
    SQL
 
    row = DB[:conn].execute(sql, name)[0]
    out = new_from_db(row)
    return out
  end 
      
    def update
    sql = <<-SQL
      UPDATE students SET name = ?, grade = ?, id = ? 
    SQL
    DB[:conn].execute(sql, self.name, self.grade, self.id)

    end 
end
