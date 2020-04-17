require_relative "../config/environment.rb"

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  attr_accessor :name, :grade
  attr_reader :id

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
      grade INTEGER
    )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS students"
    DB[:conn].execute(sql)
  end

  # update the record if it already exists, otherwise insert it to our table
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

  # creates a student and saves it
  def self.create(name, grade)
    self.new(name, grade).tap {|student| student.save}
  end

  # instantiates a new student using the array of a row from our table
  def self.new_from_db(row)
    self.new(row[1], row[2], row[0])
  end

  # find the student in the database given a name
  # return a new instance of the Student class
  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM students
    WHERE name = ?
    LIMIT 1
    SQL

    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end

  # update both name and grade of the current Student instance
  # use the ID property to ensure updating the correct row
  def update
    sql = <<-SQL
    UPDATE students SET name = ?, grade = ? WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

end
