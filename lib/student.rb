require_relative "../config/environment.rb"

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  attr_accessor :name, :grade
  attr_reader :id

  def initialize(name, grade, id=nil)
    @name = name
    @grade = grade
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE if NOT EXISTS students (
        id INTEGER PRIMARY key,
        name TEXT,
        grade TEXT
      )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE students"

    DB[:conn].execute(sql)
  end

  def save
    if self.id
      update
    else
      sql = "INSERT INTO students (name, grade) VALUES (?, ?)"

      DB[:conn].execute(sql, self.name, self.grade)

      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def self.create(name, grade)
    student = Student.new(name, grade)
    student.save
  end

  def self.new_from_db(array)
    Student.new(array[1], array[2], array[0])
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT id, name, grade FROM students
      WHERE name = ?
    SQL

    row = DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def update
    sql = <<-SQL
    UPDATE students SET name = ?, grade = ? WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end
end
