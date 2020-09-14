require_relative "../config/environment.rb"
require 'pry'

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  attr_accessor :id, :name, :grade 

  def initialize(name, grade, id=nil)
    @name = name
    @grade = grade 
    @id = id # even though default is nil and you don't generally initialize with id, still need to put this here for #new_from_db
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE students (
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
    if self.id 
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

  def self.create(name, grade)
    student = self.new(name, grade)
    student.save
  end

  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    grade = row[2]

    # we don't use save here because that will create multiple instances of same student with different id's

    student = self.new(name, grade, id) # couldn't do this if we didn't have @id = id in #initialize
    student
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM students WHERE name = ?"

    DB[:conn].execute(sql, name).map { |row| new_from_db(row) }.first
    # we use map because #execute returns the row in an array
    # we map over the array => [[]]
    # then map returns that as an array
    # so we use #first to get the first (and only) array within that array
  end

  def update
    sql = <<-SQL
      UPDATE students 
      SET name = ?, grade = ? 
      WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end


end
