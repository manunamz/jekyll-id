# Jekyll::ID

⚠️ This is gem is under active development! ⚠️

⚠️ Expect breaking changes and surprises until otherwise noted (likely by v0.1.0 or v1.0.0). ⚠️

Jekyll-ID adds ID support for jekyll markdown documents. These IDs do not change alongside document filenames, which make using the ID in a document's `permalink` attribute more reliable.

[Nanoid](https://github.com/radeno/nanoid.rb) is used to validate ID format and generate IDs.

This gem is part of the [jekyll-bonsai](https://manunamz.github.io/jekyll-bonsai/) project. 🎋

⚠️ This plugin is meant to write directly to markdown files. Always be sure to backup data and use version control.
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

```yaml
ids:
  enabled: true
  exclude: []
```

`enabled`: Set to `false` to disable the plugin. (Toggle this off if you only want to use `id`s in permalinks )

`exclude`: jekyll document types to exclude from ids processing.

`format`: set format parameters, available fields are `alpha` and `size`, see [nanoid docs](https://github.com/radeno/nanoid.rb) for details.

[nanoid defaults](https://github.com/radeno/nanoid.rb#default-options):
```yaml
ids:
  format:
    alpha: '_-0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
    size: 21
```

## Usage

This plugin assumes all target markdown files contain frontmatter.

### ID Generation

The plugin will check each markdown document's data attributes for an `id`. If none exists, it will prompt the user to generate an ID for them:

```
// ID Generation
> Generate frontmatter ID for: 
> <doc_info>
> with new ID: <new_id>
> Is that ok?
> (yes, no, yesall, or noall)
```

If `yes` or `yesall` is the response, the plugin will generate an ID and write it to the document's frontmatter in the markdown document.

### ID Replacement (Strict Mode With Formatted IDs)

If the `format` fields have been filled out in the plugin's configuration, the plugin will not only scan for the existence of an `id`, but it will check that the `id` is of the correct format. The above logic still applies, but the plugin will also ask about ID replacement when it's of an incorrect format:

```
// ID Replacement
> Replace frontmatter for: 
> <document_info> 
> with ID: <current_id> 
> with new ID: <new_id>
> Is that ok?
> (yes, no, yesall, or noall)
```

### Permalinks
This plugin adds the ability to insert `:id` into the configuration for frontmatter defaults:

```yaml
# _config.yml
defaults:
- 
    scope:
      type: "posts"
    values:
      permalink: "/post/:id/"
  - 
    scope:
      type: "entries"
    values:
      permalink: "/entry/:id/"
```

## Note:
The jekyll core will not make (post) ids permanent: https://github.com/jekyll/jekyll/issues/3725

## ToDo
Add support for GUIDs from ruby's built-in [`SecureRandom`](https://ruby-doc.org/stdlib-1.9.3/libdoc/securerandom/rdoc/SecureRandom.html#method-c-uuid)
