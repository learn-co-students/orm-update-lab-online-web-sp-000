require_relative "../config/environment.rb"

class Student
  attr_accessor :name, :grade, :id
  
  def initialize(name, grade, id = nil)
    @name = name
    @grade = grade
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY, 
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

  def self.new_from_db(row)
    # create a new Student object given a row from the database
    # row is an array
    # create new Student object
    # use elements in array row to populate object
    # return Student object
    self.new(row[1], row[2], row[0])
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

      sql_id = <<-SQL
        SELECT last_insert_rowid() FROM students
      SQL
      @id = DB[:conn].execute(sql_id)[0][0]
    end
  end

  def self.create(name, grade)
    self.new(name, grade).save
  end

  def update
    sql = <<-SQL
      UPDATE students 
      SET name = ?, grade = ?
      where id = ? 
    SQL

    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

  def self.find_by_name(name)
    # find the student in the database given a name
    # return a new instance of the Student class
    sql = <<-SQL
      select * from students 
      WHERE name = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end


end


  

