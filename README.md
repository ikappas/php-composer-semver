# PHP Composer Semver Ruby Gem

A ruby gem library for that offers utilities, version constraint parsing and validation.

This is a ruby port of the [Composer Semver Library for PHP](https://github.com/composer/semver).

## Installation / Usage
Add this line to your application's Gemfile:

```ruby
gem 'php-composer-semver'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install php-composer-semver

## Basic usage

### Comparator
The ``::Composer::Semver::Comparator`` class provides the following methods for comparing versions:

- greater_than?(v1, v2)
- greater_than_or_equal_to?(v1, v2)
- less_than?(v1, v2)
- less_than_or_equal_to?(v1, v2)
- equal_to?(v1, v2)
- not_equal_to?(v1, v2)

Each function takes two version strings as arguments. For example:
```ruby
import Composer::Semver::Comparator

Comparator::greater_than?('1.25.0', '1.24.0') # 1.25.0 > 1.24.0
````

### Semver
The ``::Composer::Semver::Semver`` class provides the following methods:

- satisfies?(version, constraints)
- satisfied_by(constraint, versions)
- sort(versions)
- rsort(versions)

## Authors
Ioannis Kappas - <ikappas@devworks.gr>

## License
PHP Composer Semver Ruby Gem is licensed under the MIT License - see the LICENSE file for details

## Contributing
1. Fork it ( https://github.com/ikappas/php-composer-semver/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
