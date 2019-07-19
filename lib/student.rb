require_relative "../config/environment.rb"

class Student
    attr_accessor :name, :grade, :id
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
        grade TEXT
      )
      SQL
      DB[:conn].execute(sql)
    end
    def self.drop_table
      sql = <<-SQL
      DROP TABLE IF EXISTS students
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
      student = Student.new(name, grade)
      student.save
      student
    end
    def self.new_from_db(row)
      new_student = Student.new(row[1], row[2], row[0])
      # new_student.id = row[0]
      # new_student.name = row[1]
      # new_student.grade = row[2]
      new_student
    end
    def self.find_by_name(name)
      sql = <<-SQL
       SELECT *
       FROM students
       where name = ?
       LIMIT 1
      SQL
      DB[:conn].execute(sql, name).map do |row|
        self.new_from_db(row)
      end.first
    end
    def self.all
      sql = <<-SQL
        SELECT * FROM students
      SQL
      DB[:conn].execute(sql).map do |row|
        self.new_from_db(row)
      end
    end
    def self.all_students_in_grade_9
      sql = <<-SQL
       SELECT *
       FROM students
       where grade = ?
      SQL
      DB[:conn].execute(sql, 9).map do |row|
        self.new_from_db(row)
      end
    end
    def self.students_below_12th_grade
      sql = <<-SQL
       SELECT *
       FROM students
       where grade < ?
      SQL
      DB[:conn].execute(sql, 12).map do |row|
        self.new_from_db(row)
      end
    end
    def self.first_X_students_in_grade_10(num)
      sql = <<-SQL
       SELECT *
       FROM students
       where grade = ?
       LIMIT ?
      SQL
      DB[:conn].execute(sql, 10, num).map do |row|
        self.new_from_db(row)
      end
    end
    def self.first_student_in_grade_10
      sql = <<-SQL
       SELECT *
       FROM students
       where grade = ?
       LIMIT 1
      SQL
      DB[:conn].execute(sql, 10).map do |row|
        self.new_from_db(row)
      end.first
    end
    def self.all_students_in_grade_X(grade)
      sql = <<-SQL
       SELECT *
       FROM students
       where grade = ?
      SQL
      DB[:conn].execute(sql, grade).map do |row|
        self.new_from_db(row)
      end
    end
    def update
      sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
      DB[:conn].execute(sql, self.name, self.grade, self.id)
    end


end
