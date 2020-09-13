require_relative "../config/environment.rb"
require 'pry'
class Student
    attr_accessor :name, :grade
    attr_reader :id
  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
    def initialize(name, grade, id = nil)
      @name = name
      @grade = grade
      @id = id
    end

    def self.create_table
      sql = <<-SQL 
        CREATE TABLE IF NOT EXISTS students (
          id TEXT PRIMARY KEY,
          name TEXT,
          grade TEXT
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

    def save #instance method
      #check if already saved
      if self.id #if id not nil, implied saved
        self.update
      else
        sql = <<-SQL 
          INSERT INTO students (name, grade) VALUES ( ?, ?)
        SQL
        DB[:conn].execute(sql, self.name, self.grade)
        #get id from result. the above statement doesn't return anything
        #instead u need to get the newly created id thru last_rowid..
        #hence u do it right away
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
        #since id is read only , no getter fucntion created, do @id instead of self.id. otherwise wont' work
      end #end if
    end #end method

    def update #instance method
      sql = <<-SQL 
      UPDATE students SET name = ?, grade = ? WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.grade, @id)
    end

    def self.create(name, grade)
      #does two steps: initialize and save. nothing fancy
      newstudent = Student.new(name, grade)
      newstudent.save
    end

    def self.new_from_db(array)
      #similar to initialize but the parameters is different)
      #the argument is the row returned by the database, but extracted so that it only has one array, not inside an outer array
      #ex: [1, "Pat", 12]
      newstudent = Student.new(array[1], array[2], array[0])
      newstudent 
    end

    def self.find_by_name(studentname)
      sql = <<-SQL 
      SELECT * FROM students WHERE name = ?
    SQL
    result = DB[:conn].execute(sql, studentname)
    #result looks like this  [[1, "Josh", "9th"]]
    Student.new_from_db(result[0])
    end

end
