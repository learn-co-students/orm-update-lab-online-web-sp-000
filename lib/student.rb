require_relative "../config/environment.rb"

class Student
  attr_accessor :name, :grade, :id

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  def initialize(name, grade)
    @name = name
    @grade = grade
  end

  def save
    if self.id
      self.update
    else
      query = <<-SQL
        INSERT INTO students
          (name, grade) VALUES (?, ?);
        SQL
      DB[:conn].execute(query, @name, @grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def update
    query = <<-SQL
      UPDATE students
        set name = ?, grade = ?
        where id = ?;
      SQL
    DB[:conn].execute(query, @name, @grade, @id)
  end

  def self.create(name, grade)
    new_student = Student.new(name, grade)
    new_student.save
    new_student
  end

  def self.new_from_db(arr)
    new_student = Student.new(arr[1], arr[2])
    new_student.id = arr[0]
    new_student
  end

  def self.find_by_name(name)
    query = <<-SQL
      select * from students
        where name = ?
        limit 1;
      SQL
    DB[:conn].execute(query, name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.create_table
    query = <<-SQL
      CREATE TABLE students
        (id INTEGER PRIMARY KEY,
        name TEXT,
        grade INTEGER
        );
      SQL
    DB[:conn].execute(query)
  end
  
  def self.drop_table
    query = <<-SQL
      DROP TABLE students;
      SQL
    DB[:conn].execute(query)
  end
end
