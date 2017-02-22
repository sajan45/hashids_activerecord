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
    def find(*args)
      scope = args.slice!(0)
      options = args.slice!(0) || {}
      if has_hashed_id? && !options[:no_hashed_id]
        if scope.is_a?(Array)
          scope.map! {|a| dehash_id(a).to_i}
        else
          scope = dehash_id(scope)
        end
      end
      super(scope)
    end

    def has_hashed_id?
      true
    end

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
    # Override ActiveRecord::Persistence#reload
    # passing in an options flag with { no_hashed_id: true }
    def reload(options = nil)
      options = (options || {}).merge(no_hashed_id: true)

      clear_aggregation_cache
      clear_association_cache

      fresh_object =
        if options && options[:lock]
          self.class.unscoped { self.class.lock(options[:lock]).find(id, options) }
        else
          self.class.unscoped { self.class.find(id, options) }
        end

      @attributes = fresh_object.instance_variable_get('@attributes')
      @new_record = false
      self
    end
  end
end
ActiveRecord::Base.extend HashidsActiverecord
