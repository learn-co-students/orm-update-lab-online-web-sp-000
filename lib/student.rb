require_relative "../config/environment.rb"

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  attr_accessor :name, :grade, :id

  def initialize(name, grade, id = nil)
    @name = name
    @grade = grade
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

  def self.create(name, grade)
    student = Student.new(name, grade, id = nil)
    student.save
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

  def self.new_from_db(row)
    @name = row[1]
    @grade  = row[2]
    student = Student.new(@name, @grade)
    student.id =  row[0]
    student
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM students
    WHERE name = ?
    LIMIT 1
    SQL

    row = DB[:conn].execute(sql, name)[0]
    self.new_from_db(row)
  end

  def update
    sql = <<-SQL
    UPDATE students SET name = ?, grade = ? 
    WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

end
