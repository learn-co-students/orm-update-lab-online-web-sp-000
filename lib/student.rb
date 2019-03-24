require_relative "../config/environment.rb"

class Student
  attr_accessor :name, :grade
  attr_reader :id

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  def initialize(name, grade, id=nil)
    @name = name
    @grade = grade
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      create table if not exists students(
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade INTEGER)
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      drop table if exists students
    SQL

    DB[:conn].execute(sql)
  end

  def save
    if @id
      update
    else
      sql = <<-SQL
        insert into students(name, grade)
        values (?, ?)
      SQL

      DB[:conn].execute(sql, @name, @grade)

      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students").flatten[0]
    end
  end

  def self.create(name, grade)
    s = Student.new(name, grade)
    s.save
    s
  end

  def update
    sql = <<-SQL
      update students
      set name = ?, grade = ?
      where id = ?
    SQL

    DB[:conn].execute(sql, @name, @grade, @id)
  end

  def self.new_from_db(row)
    s = Student.new(row[1], row[2], row[0])
  end

  def self.find_by_name(name)
    sql = <<-SQL
      select * from students where name = ? limit 1
    SQL

    new_from_db(DB[:conn].execute(sql, name).flatten)
  end
end
