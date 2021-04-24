# Doure

Doure is a minimal abstraction to write parameterized filters for ActiveRecord models. It allows you to write named filters that accept one parameter, and use those later with `doure_filter`, ex:

```ruby
class Post < ApplicationRecord
  include Doure::Filterable

  filter_class PostFilter
end

class PostFilter < Doure::Filter
  cont_filter(:title)
  filter(:author_role_in) { |s, v| s.joins(:author).where(authors: { role: v }) }
end

Post.doure_filter(title_cont: "Dev", author_role_in: ["editor", "admin"])
```

This allows for a simple implementation of search features in a controller, by passing the "search" parameters (like a `q` parameter) directly to `#doure_filter`.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'doure'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install doure

## Usage

Given you have an ActiveRecord model, you need to extend the filterable module and define which class you will use to declare the filters, for example:

```ruby
# app/models/post.rb

class Post < ApplicationRecord
  include Doure::Filterable
  
  filter_class PostFilter
end
```

Then declare the filters in that class, inheriting from `Doure::Filter`:

```ruby
# app/filters/post_filter.rb

class PostFilter < Doure::Filter
  cont_filter(:title)
  filter(:author_role_in) { |s, v| s.joins(:author).where(authors: { role: v }) }
end
```

### Declaring filters

Each filter has a name and receive a parameter, which you use to implement the desired clause. 

The most basic method to declare filters is `filter(name, &block)`. The block receives an AR relation and the value, and must return another AR relation. 

You can also use the additional argument `:as` to `filter` (or any of the other predefined filters) in order to apply an automatic casting to the value passed from `Model#filter(hash)`. Example:

```ruby
class PostFilter < Doure::Filter
  filter(:is_visible, as: :boolean) { |s, v|
    # 'v' is a boolean here even if used as `Post.doure_filter(is_visible: 'true')` 
    s.where(active: v) 
  }
end
```

The supported type castings are:

- `:boolean`: Will be casted using the default Rails semantics around booleans coming from forms, so that '1', 'true', 'T', etc will be `true`. See: https://github.com/rails/rails/blob/47eadb68bfcae1641b019e07e051aa39420685fb/activemodel/lib/active_model/type/boolean.rb#L17

- `:date`: Will be casted using `Date.parse`

- `:datetime`: Will be casted using `Time.parse` 

If you want to modify or extend the supported type castings, you can always define the `cast_value(type, value)` method on the filter class. Ex:

```ruby
class PostFilter < Doure::Filter
  eq_filter(:publish_date, as: :special_date_format)
  
  def cast_value(type, value)
    case type
      when :special_date_format
        Date.strptime(value, "formatting string")
      else
        super
    end
  end
end
```


### Predefined filters

Some of the most commonly used filters are already provided. The name of the resulting filter is always <filter_name>_<prefix>, for example "title_cont" for a filter like "cont_filter(:title)". In particular the provided filters are:

- `cont_filter(name)`: Implements `ILIKE '%#{value}%'`. Ex: `Post.doure_filter(title_cont: 'dev')`
- `eq_filter(name)`: Implements equality. Ex: `Post.doure_filter(id_eq: 12)`
- `not_eq_filter(name)`: Non-equality. Ex: `Post.doure_filter(id_not_eq: 12)`
- `present_filter(name)`: This is a boolean filter by default. Implements equality / non-equality against NULL. Ex: `Post.doure_filter(slug_present: false)`
-  Numerical comparators, `gt_filter, lt_filter, gteq_filter, lteq_filter`: Implements numerical comparators, the passed value is left as-is. Ex: `Post.doure_filter(views_count_gt: 10)` 


### Using Model#filter

The `#filter` method is chainable with other scopes, for example:

`Post.where(category_id: 12).doure_filter(title_cont: "Dev")`

Or with named scopes you have declared in the model:

`Post.not_deleted.visible.doure_filter(title_cont: "Dev", category_id_eq: '88')`

The expected use case for Doure is to implement search features. Since it's a common scenario to use `Model#filter` passing a hash of values coming from a view form, the hash will usually have most of their keys with nil values or empty strings. In order to not give incorrect results, then, `nil` and the empty string (`""`) values are ignored by default. For example:

`Post.doure_filter(title_cont: "", is_visible: "f")`

Will only apply the `is_visible` filter but not the `title_cont`.  

 
### FAQ

- The equality filters are not working when using nil values. 

Since nil and empty strings are ignored by default, the equality with nil is not a supported scenario. Instead, you can create an specific presence filter for this (`present_filter(:title)`). 



## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rogercampos/doure.
