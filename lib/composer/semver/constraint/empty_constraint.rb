#
# This library was ported to ruby from php source code files.
# Original Source: Composer\Semver\Constraint\EmptyConstraint.php
#
# (c) Composer <https://github.com/composer>
#
# For the full copyright and license information, please view the LICENSE
# file that was distributed with this source code.
#

module Composer
  module Semver
    module Constraint
      class EmptyConstraint < ::Composer::Semver::Constraint::Base

        def matches?(_provider)
          true
        end

        def match_specific?(_provider)
          true
        end

        def pretty_string=(pretty_string)
          @pretty_string = pretty_string
        end

        def pretty_string
          return to_s unless @pretty_string
          @pretty_string
        end

        def to_s
          '[]'
        end
      end
    end
  end
end
