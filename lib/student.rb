require_relative "../config/environment.rb"

class Student
    attr_accessor :id, :name, :grade 
    
    def initialize(id = nil, name, grade)
      @name = name
      @grade = grade 
    end 
    
    def self.create_table 
      sql = "CREATE TABLE IF NOT EXISTS students (id INTEGER PRIMARY KEY, name TEXT, grade TEXT)"
      
      DB[:conn].execute(sql)
      
    end 
    
    def self.drop_table 
      sql = "DROP TABLE IF EXISTS students"
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
      student.save 
      student 
    end 
  
    def self.new_from_db(row)
      student = self.new 
      student.id = row[0]
      student.name = row[1]
      student.grade = row[2]
      student 
    end 
  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  
  def self.find_by_name(name)
    sql = "SELECT * FROM students WHERE name = ? LIMIT 1"
    DB[:conn].execute(sql, name).map do |row| 
        self.new_from_db(row)
      end.first 
  end 
  
  def update
    sql = "UPDATE songs SET name = ?, album = ? WHERE id = ?" 
    DB[:conn].execute(sql, self.name, self.album, self.id)
  end


end
