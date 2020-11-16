require_relative "../config/environment.rb"

class Student

  attr_accessor :name, :grade
  attr_reader :id

  def initialize(id = nil, name, grade)
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

    sql = "DROP TABLE students"
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      sql_update = <<-SQL
        UPDATE students
        SET name = ?, grade = ?
        WHERE id = #{id}
      SQL
      DB[:conn].execute(sql_update, name, grade)
    else
      sql_save = <<-SQL
        INSERT INTO students (name, grade)
        VALUES (?, ?)
      SQL
      DB[:conn].execute(sql_save, name, grade)
      sql_id = <<-SQL
        SELECT last_insert_rowid() FROM students
      SQL
      @id = DB[:conn].execute(sql_id).flatten.first
    end
  end

  def self.create(name, grade)
    student_new = self.new(name, grade)
    student_new.save
    student_new
  end

  def self.new_from_db(row)
    student_new = self.new(row[0], row[1], row[2])
    student_new
  end

  def self.find_by_name(name)

    sql = "SELECT * FROM students WHERE name = ?"

    result = DB[:conn].execute(sql, name)[0]
    self.new_from_db(result)
  end

  def update

    sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.grade, self.id)

  end


end
