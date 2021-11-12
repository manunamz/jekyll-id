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

```yml
ids:
  enabled: true
  exclude: []
```

`enabled`: set to `false` to disable the plugin.

`exclude`: jekyll document types to exclude from ids processing.

`format`: set format parameters; available are `alpha` and `size`, see [nanoid docs](https://github.com/radeno/nanoid.rb) for details.

ex:
```yml
ids:
  format:
    alpha: '1234567890abcdef'
    size: 10
```

## Usage

TODO: Write usage instructions here

This plugin assumes all target markdown files contain frontmatter.

## Why?
The jekyll core will not make (post) ids permanent: https://github.com/jekyll/jekyll/issues/3725

## ToDo
Add support for GUIDs from ruby's built-in [`SecureRandom`](https://ruby-doc.org/stdlib-1.9.3/libdoc/securerandom/rdoc/SecureRandom.html#method-c-uuid)
