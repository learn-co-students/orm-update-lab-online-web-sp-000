require_relative "../config/environment.rb"
require 'pry'

class Student
  attr_accessor :id, :name, :grade

  def initialize(id = nil, name, grade)
    @name = name
    @grade = grade
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
    sql = <<-SQL
      DROP TABLE students
      SQL

    DB[:conn].execute(sql)
  end

  def save
    if @id
      self.update
    else    
      sql = <<-SQL
        INSERT INTO students (name, grade)
        VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.grade)

      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def update
    sql = <<-SQL
      UPDATE students
      SET name = ?, grade = ?
      WHERE id = ?
      SQL

    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

  def self.create(name, grade)
    new_student = Student.new(name, grade)
    new_student.save
    new_student
  end

  def self.new_from_db(row)
    name = row[1]
    grade = row[2]
    new_student = self.create(name, grade)
    new_student.id = row[0]
    new_student

    #alternative - not sure which is faster or if one is faster
    # new_student = self.new
    # new_student.id = row[0]
    # new_student.name = row[1]
    # new_student.grade = row[2]
    # new_student
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM students
      WHERE name = ?
      SQL
      # binding.pry
      DB[:conn].execute(sql,name).map do |row|
        self.new_from_db(row)
      end.first
    # This works as well. 
    #self.new_from_db(DB[:conn].execute(sql, name).first)
  end
end
