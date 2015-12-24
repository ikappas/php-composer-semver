#
# This library was ported to ruby from php source code files.
# Original Source: Composer\Semver\Semver.php
#
# (c) Composer <https://github.com/composer>
#
# For the full copyright and license information, please view the LICENSE
# file that was distributed with this source code.
#

module Composer
  module Semver
    class Semver

      SORT_ASC = 1
      SORT_DESC = -1

      class << self

        # Determine if given version satisfies given constraints.
        #
        # @param version string
        # @param constraints string
        #
        # @return bool
        def satisfies?(version, constraints)
          provider = ::Composer::Semver::Constraint::Constraint.new('==', self.version_parser.normalize(version))
          constraints = self::version_parser.parse_constraints(constraints)
          constraints.matches?(provider)
        end

        # Return all versions that satisfy given constraints.
        #
        # @param versions array
        # @param constraints string
        #
        # @return array
        def satisfied_by(versions, constraints)
          satisfied = []
          # versions.select {|version| self::satisfies?(version, constraints) }
          versions.map do |version|
            if self::satisfies?(version, constraints)
              satisfied << version
            end
          end
          satisfied
        end

        # Sort given array of versions.
        #
        # @param versions array
        #
        # @return array
        def sort(versions)
          self::usort(versions, self::SORT_ASC)
        end

        # Sort given array of versions in reverse.
        #
        # @param versions array
        #
        # @return array
        def rsort(versions)
          self::usort(versions, self::SORT_DESC)
        end

        protected

        # @var VersionParser */
        def version_parser
          @version_parser ||= ::Composer::Semver::VersionParser.new
        end

        # @param versions array
        # @param direction integer
        #
        # @return array
        def usort(versions, direction)
          # if @@version_parser.nil?
          #     @@version_parser = ::Composer::Semver::VersionParser.new()
          # end

          # version_parser = @@version_parser
          normalized = []

          # Normalize outside of usort() scope for minor performance increase.
          # Creates an array of arrays: [[normalized, key], ...]
          versions.each_index { |i| normalized.push({ normalized: self::version_parser.normalize(versions[i]), index: i }) }

          normalized_sorted = normalized.sort {|a,b| apply_sorting(a, b, direction)}

          # Recreate input array, using the original indexes which are now in sorted order.
          sorted = []
          normalized_sorted.each do |item|
            sorted.push versions[item[:index]]
          end

          sorted
        end

        def apply_sorting(left, right, direction)

          if left[:normalized] === right[:normalized]
            return 0
          end

          if ::Composer::Semver::Comparator::less_than?(left[:normalized], right[:normalized])
            return -direction
          end

          direction
        end
      end
    end
  end
end
