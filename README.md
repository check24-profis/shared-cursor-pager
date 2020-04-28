# CursorPager

![build](https://github.com/askcharlie/cursor_pager/workflows/CI/badge.svg) [![Gem Version](https://badge.fury.io/rb/cursor_pager.svg)](https://badge.fury.io/rb/cursor_pager)

A small and easy-to-use library that aims to make it easy to build Rails APIs
with cursor-based pagination (aka keyset pagination).

It aims to support the [JSON API Cursor Pagination] and [Relay's GraphQL Cursor
Connection] specs.

Stable ordering is essential for cursor-based pagination. The gem will
automatically add additional sorting by primary key if the relation passed
into the page isn't already ordered by the primary key or a datetime column.

## Installation

CursorPager is compatible with ActiveRecord 6.0 and 5.2 on Ruby 2.6 and later.

Add this line to your application's Gemfile:

```ruby
gem "cursor_pager"
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install cursor_pager

## Usage

To fetch the first ten users:


```ruby
page = CursorPager::Page.new(User.all, first: 10)
page.records
```

To get information about the page or generate a cursor

```ruby
page.previous_page?                # Tells you if there is a previous page
page.next_page?                    # Tells you if there is a next page
page.cursor_for(page.records.last) # Generates a cursor for a specific item
page.first_cursor                  # Generates a cursor for the first item
page.last_cursor                   # Generates a cursor for the last item
```

To fetch the first then usres after a certain cursor

```ruby
page = CursorPager::Page.new(User.all, first: 10, after: "MTA=")
page.records

```

To paginate backwards

```ruby
page = CursorPager::Page.new(User.all, last: 10, before: "NTA=")
page.records
```

## Configuration

### Encoder

By default cursors are base64 encoded primary keys of the records. If you wish
to change that because you want to add encryption or something similiar, you
can provide your own encoder class.

```ruby
class CustomEncoder
  def encode(data)
    # Your encoding logic
  end

  def decode(data)
    # Your decoding logic
  end
end

CursorPager.configure do |config|
  config.encoder = CustomEncoder
end
```

### Default & Maximum Page Size

The default & maximum page sizes are configured as `nil` (unlimited) by default.
You can however set your own values.

```ruby
CursorPager.configure do |config|
  config.default_page_size = 25
  config.maximum_page_size = 100
end
```

## Not (yet) supported

* Ordering by SQL alias or function
* Ordering by multiple columns in different directions

## Contributing

Bug reports and pull requests are welcome on GitHub. This project is intended
to be a safe, welcoming space for collaboration, and contributors are expected
to adhere to the [code of conduct].


## License

The gem is available as open source under the terms of the [MIT License].

[JSON API Cursor Pagination]: https://jsonapi.org/profiles/ethanresnick/cursor-pagination/
[Relay's GraphQL Cursor Connection]: https://relay.dev/graphql/connections.htm
[code of conduct]: https://github.com/askcharlie/cursor_pager/blob/master/CODE_OF_CONDUCT.md
[MIT License]: https://opensource.org/licenses/MIT
