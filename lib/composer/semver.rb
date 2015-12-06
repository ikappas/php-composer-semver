#
# This library was ported to ruby from php source code files.
#
# (c) Composer <https://github.com/composer>
#
# For the full copyright and license information, please view the LICENSE
# file that was distributed with this source code.
#

module Composer
  module Semver

    GEM_VERSION = '1.2.0'

    autoload :Semver,        'composer/semver/semver'
    autoload :VersionParser, 'composer/semver/version_parser'
    autoload :Comparator,    'composer/semver/comparator'

    module Constraint

      autoload :Base, 'composer/semver/constraint/base'
      autoload :Constraint, 'composer/semver/constraint/constraint'
      autoload :EmptyConstraint, 'composer/semver/constraint/empty_constraint'
      autoload :MultiConstraint, 'composer/semver/constraint/multi_constraint'

    end

  end
end
