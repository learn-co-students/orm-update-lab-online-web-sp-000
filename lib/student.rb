require_relative "../config/environment.rb"

class Student

  attr_accessor :name, :grade, :id

  def initialize (name, grade, id = nil)
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
      );
    SQL
    DB[:conn].execute(sql)  
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE students")    
  end
  
  def save
    if DB[:conn].execute("SELECT id FROM students WHERE id = ?", @id).count == 0
      Student.create(@name, @grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]    
    else      
      self.update
    end
  end

  def self.create(name, grade)
    student = DB[:conn].execute("INSERT INTO students (name, grade) VALUES (?, ?)", name, grade)
  end

  def self.new_from_db(row)
    Student.new(row[1], row[2], row[0])
  end

  def self.find_by_name(name)
    Student.new_from_db(DB[:conn].execute("SELECT * FROM students WHERE name = ?", name).flatten)
  end

  def update
    DB[:conn].execute("UPDATE students SET name = ?, grade = ? WHERE id = ?", @name, @grade, @id)
  end
end
