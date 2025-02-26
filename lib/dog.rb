class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(id: nil, name:, breed:)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE IF EXISTS dogs
    SQL

    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
      INSERT INTO dogs (name, breed) VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]

      self
    end
  end

  def update
    sql = <<-SQL
    UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.create(hash)
    new_dog = Dog.new(hash)
    new_dog.save
    new_dog
  end

  def self.new_from_db(row)
    attribute_values = {
      :id => row[0],
      :name => row[1],
      :breed => row[2]
    }

    Dog.new(attribute_values)
  end

  def self.find_by_id(id)
    sql = <<-SQL
    SELECT * FROM dogs WHERE id = ?
    SQL

    DB[:conn].execute(sql, id).map(){|row|
      self.new_from_db(row)
    }.first
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
    SELECT id FROM dogs WHERE name = ? AND breed = ?
    SQL

    dog = DB[:conn].execute(sql, name, breed)[0]

    if dog
      new_dog = self.new_from_db(dog)
    else
      new_dog = self.create({name: name, breed: breed})
    end
    new_dog
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM dogs WHERE name = ?
    SQL

    DB[:conn].execute(sql, name).map(){|row|
      dog = self.new_from_db(row)
    }.first
  end

end
