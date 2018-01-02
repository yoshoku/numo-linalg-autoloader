# Numo::Linalg::Autoloader

[![Build Status](https://travis-ci.org/yoshoku/numo-linalg-autoloader.svg?branch=master)](https://travis-ci.org/yoshoku/numo-linalg-autoloader)
[![Gem Version](https://badge.fury.io/rb/numo-linalg-autoloader.svg)](https://badge.fury.io/rb/numo-linalg-autoloader)

Numo::Linalg::Autoloader is a module that has a method loading backend libraries automatically
according to an execution environment.
The library is confirmed to work with Intel MKL and OpenBLAS (installed from source)
on macOS, Ubuntu, and CentOS.
Moreover, the library currently does not support ATLAS.

If you want to set the backend library yourself,
you should refear to the [official document](https://github.com/ruby-numo/linalg/blob/master/doc/select-backend.md).

Note that the library is made for personal convenience and has no direct relationships with
the [Ruby/Numo](https://github.com/ruby-numo/numo/blob/master/README.md) project.
I would like to express my gratitude to the authors of
[Numo::NArray](https://rubygems.org/gems/numo-narray) and
[Numo::Linalg](https://rubygems.org/gems/numo-linalg).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'numo-linalg-autoloader'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install numo-linalg-autoloader

## Usage

```ruby
require 'numo/linalg/autoloader'
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then,
run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that
will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.
To release a new version, update the version number in `version.rb`,
and then run `bundle exec rake release`, which will create a git tag for the version,
push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/yoshoku/numo-linalg-autoloader.
This project is intended to be a safe, welcoming space for collaboration,
and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [BSD 3-clause License](https://opensource.org/licenses/BSD-3-Clause).

## Code of Conduct

Everyone interacting in the Numo::Linalg::Autoloader project’s codebases, issue trackers,
chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/yoshoku/numo-linalg-autoloader/blob/master/CODE_OF_CONDUCT.md).
