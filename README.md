# Jekyll::ID

⚠️ This is gem is under active development! ⚠️

⚠️ Expect breaking changes and surprises until otherwise noted (likely by v0.1.0 or v1.0.0). ⚠️

Jekyll-ID adds unique id support for jekyll markdown documents.

This gem is part of the [jekyll-bonsai](https://manunamz.github.io/jekyll-bonsai/) project. 🎋
## Installation

Add this line to your application's Gemfile:

```ruby
gem 'jekyll-id'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install jekyll-id


## Configuration

Defaults look like this:

```
ids:
  enabled: true
  exclude: []
  format:
    alpha: ''
    size: 0
```

`enabled`:

`exclude`:

`format`: 

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Why?
The jekyll core will not make (post) ids permanent: https://github.com/jekyll/jekyll/issues/3725

## ToDo
Add support for GUIDs from ruby's built-in [`SecureRandom`](https://ruby-doc.org/stdlib-1.9.3/libdoc/securerandom/rdoc/SecureRandom.html#method-c-uuid)
