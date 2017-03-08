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

## Customization

The `hashid` method will accept some options for better customization:
* **hash_salt** : You can pass your own `hash_salt` for more unique hashed result
  from others, using this plugin. By default, it uses **Table name** as salt. For example,
  `User` model will be hashed with `users` as salt.

    hashid :encrypted_id, hash_salt: 'my custom salt'

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
