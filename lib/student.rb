require_relative "../config/environment.rb"

class Student
    attr_accessor :name, :grade, :id 

    def initialize(name,grade, id=nil)
      @name = name 
      @grade = grade 
      
    end 

    def self.create_table 
      sql = "CREATE TABLE IF NOT EXISTS students (
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
      end 
      sql = "INSERT INTO students (name,grade) VALUES (?,?)"
      DB[:conn].execute(sql,self.name,self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end 

    def update 
      sql = "UPDATE students SET name = ?, grade= ? WHERE id= ?"
      DB[:conn].execute(sql,self.name,self.grade,self.id)
    end 
    
    def self.create(name, grade)
      student = Student.new(name,grade)
      student.save
    end 
    
    def self.new_from_db(row)
      sql = "INSERT INTO students (name, grade) VALUES (?,?)"
      row = Student.new(:name, :grade)
      DB[:conn].execute(row)
    end 
end
