class Dog
  attr_accessor :id, :name, :breed
  
  def initialize(id:nil, new_name:, new_breed:)
    @id = id
    @name = new_name
    @breed = new_breed
  end
  
  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end
    
  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end
  
  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
  
  def save
    # Saves an instance of  dog class to the db and then 
    # sets the given dogs `id` attribute
    if self.id 
      self.update
    else 
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL
      
      DB[:conn].execute(sql,self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    # Returns an instance of the dog class
    self
  end
  
  # Takes in a hash of attributes and uses metaprogramming to create a new dog object
  # Then it uses the #save method to save that dog to the database
  def self.create(name:, breed:)
    dog = Dog.new(new_name: name, new_breed: breed)
    dog.save
    dog
  end
  
  # creates an instance with corresponding attribute values
  def self.new_from_db(row)
    new_dog = Dog.new(id: row[0], new_name: row[1], new_breed: row[2])
    new_dog
  end
end