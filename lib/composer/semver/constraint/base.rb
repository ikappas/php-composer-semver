#
# This library was ported to ruby from php source code files.
# Original Source: Composer\Semver\Constraint\AbstractConstraint.php
#
# (c) Composer <https://github.com/composer>
#
# For the full copyright and license information, please view the LICENSE
# file that was distributed with this source code.
#

module Composer
  module Semver
    module Constraint
      class Base

        def pretty_string=(pretty_string)
          @pretty_string = pretty_string
        end

        def pretty_string
          return to_s unless @pretty_string
          @pretty_string
        end

        def matches?(provider)
          unless provider.kind_of?(::Composer::Semver::Constraint::Base)
            raise ArgumentError,
                  'The "provider" must be a subclass of Composer::Semver::Constraint::Base'
          end

          if provider.instance_of?(self.class)
            match_specific?(provider)
          else
            provider.matches?(self)
          end
        end

        def match_specific?(provider)
          raise NotImplementedError
        end

      end
    end
  end
end
