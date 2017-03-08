# hashids_activerecord
Use [hashids.rb](https://github.com/peterhellberg/hashids.rb) to obfuscate the ActiveRecord ID and save it to the table as the specified attribute and also uses it in URL created by path helpers.

## Installation

Add the gem to your Gemfile:

    gem 'hashids_activerecord', github: 'sajan45/hashids_activerecord'

## Usage

Add a single line like below, in your model.

```ruby
class Order < ActiveRecord::Base
  hashid :encrypted_id
end
```
In above code, `encrypted_id` is the column name to which you want to save the
hashed id. Please make sure that, the column exists for that particular
model before using that column for storing hashed id. This gem **will not** create
migration or column for you. You have to create it.

Find a Record:

If you want to find a record by the hashed id, you can easily use the attribute,
which used while defining the `hashid`. For above example:

    Order.find_by_encrypted_id("AhXC23m") # if hashed id is 'AhXC23m'

Or if you want to dehash it and find the original id then:

    Order.dehash_id("AhXC23m") # => 4 , if the original id was 4

Here `dehash_id` is a class method, available on every model which uses hashid.

#### Use in path helper:
Pass the full object to the path helper and Rails will use the encrypted column name
to identify the Record.

    order_path(@order)

Here, if `@order` has hashed id as 'AhXC23m' then it will generate path as
`order/AhXC23m` . Instead of using default `id`, it will use hashed id in url.

**Note** : Since it will use hashed id in url, when you are trying to use this
id to fetch then you will have to use it like this:

    Order.find_by(encrypted_id: params[:encrypted_id])

Considering that the column name is `encrypted_id`, which stores hashed ids.
If you find using `find_by` more frequently due to this reason, you can override the
`find` method for that specific model like:

(As you may have understood, this is optional. Not mandatory.)
```ruby
class Order < ActiveRecord::Base
  hashid :encrypted_id

  self.find(*args)
    scope = args.slice!(0)
    options = args.slice!(0) || {}
    if !options[:no_hashed_id]
      if scope.is_a?(Array)
        scope.map! {|a| dehash_id(a).to_i}
      else
        scope = dehash_id(scope)
      end
    end
    super(scope)
  end
end
```

In this way, calling the normal find method will **always** decrypt the hashid to normal id first
and then it will try to find the object using that id.

    Order.find(params[:encrypted_id])

Or if you have object's default id, not the hashed id then use the `find` method like:

    Order.find(4, no_hashed_id: true)

## Customization

The `hashid` method will accept some options for better customization:
* **hash_salt** : You can pass your own `hash_salt` for more unique hashed result
  from others, using this plugin. By default, it uses **Table name** as salt. For example,
  `User` model will be hashed with `users` as salt.

    `hashid :encrypted_id, hash_salt: 'my custom salt'`

* **min_length** : You can use this option to configure, how many minimum characters you want in
  the hashed id.

    `hashid :encrypted_id, min_length: 5`

* **alphabets** : Use this option when you want to control the characters in hashed id.

    `hashid :encrypted_id, alphabets: "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"`

    Using the above code, will generate hashed id consisting of only Capital alphabets and numbers.
    Default alphabets are "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890"

## Limitation

This is not a plain Ruby Gem. It is a Rails plugin, which extends ActiveRecord. So it should
be only used with Rails.
