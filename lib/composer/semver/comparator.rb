#
# This library was ported to ruby from php source code files.
# Original Source: Composer\Semver\Comparator.php
#
# (c) Composer <https://github.com/composer>
#
# For the full copyright and license information, please view the LICENSE
# file that was distributed with this source code.
#

module Composer
  module Semver
    class Comparator
      class << self
      
        # Evaluates the expression: version1 > version2.
        #
        # @param version1 The version 1 string.
        # @param version2 The version 2 string.
        #
        # @return bool
        def greater_than?(version1, version2)
          self::compare?(version1, '>', version2)
        end
      
        # Evaluates the expression: version1 >= version2.
        #
        # @param version1 The version 1 string.
        # @param version2 The version 2 string.
        #
        # @return bool
        def greater_than_or_equal_to?(version1, version2)
          self::compare?(version1, '>=', version2)
        end
      
        # Evaluates the expression: version1 < version2.
        #
        # @param version1 The version 1 string.
        # @param version2 The version 2 string.
        #
        # @return bool
        def less_than?(version1, version2)
          self::compare?(version1, '<', version2)
        end
      
        # Evaluates the expression: version1 <= version2.
        #
        # @param version1 The version 1 string.
        # @param version2 The version 2 string.
        #
        # @return bool
        def less_than_or_equal_to?(version1, version2)
          self::compare?(version1, '<=', version2)
        end
      
        # Evaluates the expression: version1 == version2.
        #
        # @param version1 The version 1 string.
        # @param version2 The version 2 string.
        #
        # @return bool
        def equal_to?(version1, version2)
          self::compare?(version1, '==', version2)
        end
      
        # Evaluates the expression: version1 != version2.
        #
        # @param version1 The version 1 string.
        # @param version2 The version 2 string.
        #
        # @return bool
        def not_equal_to?(version1, version2)
          self::compare?(version1, '!=', version2)
        end
      
        # Evaluates the expression: version1 operator version2.
        #
        # @param version1 The version 1 string.
        # @param operator The operator to perform the comparison.
        # @param version2 The version 2 string.
        #
        # @return bool
        def compare?(version1, operator, version2)
          constraint = ::Composer::Semver::Constraint::Constraint.new(operator, version2)
          constraint.matches?(::Composer::Semver::Constraint::Constraint.new('==', version1))
        end
      
      end
    end
  end
end
