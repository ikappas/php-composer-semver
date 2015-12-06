#
# This library was ported to ruby from php source code files.
# Original Source: Composer\Semver\Constraint\MultiConstraint.php
#
# (c) Composer <https://github.com/composer>
#
# For the full copyright and license information, please view the LICENSE
# file that was distributed with this source code.
#
module Composer
  module Semver
    module Constraint
      class MultiConstraint < ::Composer::Semver::Constraint::Base

        # Sets operator and version to compare a package with
        #
        # @param constraints array A set of constraints
        # @param conjunctive bool Whether the constraints should be treated as conjunctive or disjunctive
        def initialize(constraints, conjunctive = true)
          @constraints = constraints
          @conjunctive = conjunctive
        end

        def matches?(provider)

          raise ArgumentError,
                'The "provider" argument is invalid' unless provider.kind_of?(::Composer::Semver::Constraint::Base)

          unless @conjunctive
            @constraints.each do |constraint|
              return true if constraint.matches?(provider)
            end
            false
          else
            @constraints.each do |constraint|
              if !constraint.matches?(provider)
                return false
              end
            end
            true
          end
        end

        def match_specific?(provider)

          raise ArgumentError,
                'The "provider" argument is invalid' unless provider.instance_of?(self.class)

          matches?(provider)
        end

        def pretty_string=(pretty_string)
          @pretty_string = pretty_string
        end

        def pretty_string
          return to_s unless @pretty_string
          @pretty_string
        end

        def to_s
          constraints = []
          unless @constraints.nil?
            @constraints.each do |constraint|
              constraints << String(constraint)
            end
          end
          if @conjunctive.nil?
            separator = ' '
          else
            separator = @conjunctive ? ' ' : ' || '
          end
          "[#{constraints.join(separator)}]"
        end
      end
    end
  end
end
