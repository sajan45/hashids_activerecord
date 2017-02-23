module HashidsActiverecord
  def hashid(name, options = {})
    require 'hashids'
    extend ClassMethods
    include InstanceMethods
    cattr_accessor :hash_salt, :min_length, :alphabets, :col_name
    self.hash_salt  = (options[:salt] || default_salt)
    self.min_length = (options[:min_length] || 3)
    self.alphabets  = (options[:alphabets] || Hashids::DEFAULT_ALPHABET)
    self.col_name = name
    after_create do |record|
      record.save_hashid_to(name)
    end
  end

  def self.hide(id, salt, min_length, alphabets)
    hashids = Hashids.new(salt, min_length, alphabets)
    hashids.encode id
  end

  def self.show(id, salt, min_length, alphabets)
    hashids = Hashids.new(salt, min_length, alphabets)
    decoded = hashids.decode id
    decoded[0] if decoded
  end

  module ClassMethods

    def dehash_id(hashed_id)
      HashidsActiverecord.show(hashed_id, self.hash_salt, self.min_length, self.alphabets)
    end

    # Generate a default salt from the Table name
    def default_salt
      self.table_name
    end
  end

  module InstanceMethods
    def to_param
      self[self.class.col_name]
    end

    def save_hashid_to(column_name)
      self[column_name] = HashidsActiverecord.hide(self.id,
                                                   self.class.hash_salt,
                                                   self.class.min_length,
                                                   self.class.alphabets)
      self.save
    end
  end
end
ActiveRecord::Base.extend HashidsActiverecord
