#
# This library was ported to ruby from php source code files.
# Original Source: Composer\Semver\Constraint\Constraint.php
#
# (c) Composer <https://github.com/composer>
#
# For the full copyright and license information, please view the LICENSE
# file that was distributed with this source code.
#

module Composer
  module Semver
    module Constraint
      class Constraint < ::Composer::Semver::Constraint::Base

        # attr_reader :operator, :version

        # operator integer values
        OP_EQ = 0
        OP_LT = 1
        OP_LE = 2
        OP_GT = 3
        OP_GE = 4
        OP_NE = 5

        # Get all supported comparison operators.
        #
        # Return: array
        def self.supported_operators
          self.trans_op_str.keys
        end

        # Operator to integer translation table.
        def self.trans_op_str
          @trans_op_str ||= {
              '='  => OP_EQ,
              '==' => OP_EQ,
              '<'  => OP_LT,
              '<=' => OP_LE,
              '>'  => OP_GT,
              '>=' => OP_GE,
              '<>' => OP_NE,
              '!=' => OP_NE,
          }.freeze
        end

        # Integer to operator translation table.
        def self.trans_op_int
          @trans_op_int ||= {
              OP_EQ => '==',
              OP_LT => '<',
              OP_LE => '<=',
              OP_GT => '>',
              OP_GE => '>=',
              OP_NE => '!=',
          }.freeze
        end

        def initialize(operator, version)

          if self.class.trans_op_str[operator].nil?
            raise ArgumentError,
                  "Invalid operator \"#{operator}\" given, expected one of: #{self.class.supported_operators.join(', ')}"
          end

          @operator = self.class.trans_op_str[operator]
          @version = version
        end

        def version_compare(a, b, operator, compare_branches = false)

          a_is_branch = a.start_with?('dev-') rescue false
          b_is_branch = b.start_with?('dev-') rescue false

          # when both a and b are branches
          if a_is_branch && b_is_branch
            return operator === '==' && a === b
          end

          # when branches are not comparable, we make sure dev branches never match anything
          unless compare_branches
            if a_is_branch || b_is_branch
              return false
            end
          end

          # compare the versions
          compare = php_version_compare(a, b)
          case operator
          when '>', 'gt'
            return compare > 0
          when '>=', 'ge'
            return compare >= 0
          when '<=', 'le'
            return compare <= 0
          when '==', '=', 'eq'
            return compare == 0
          when '<>', '!=', 'ne'
            return compare != 0
          when '', '<', 'lt'
            return compare < 0
          end

          false
        end

        def match_specific?(provider, compare_branches = false)

          raise ArgumentError,
                'The "provider" must be a subclass of Composer::Semver::Constraint::Base' unless provider.kind_of?(self.class)

          no_equal_op = self.class.trans_op_int[operator].delete('=')
          provider_no_equal_op = self.class.trans_op_int[provider.operator].delete('=')

          is_equal_op = operator.equal?(OP_EQ)
          is_non_equal_op = operator.equal?(OP_NE)
          is_provider_equal_op = provider.operator.equal?(OP_EQ)
          is_provider_non_equal_op = provider.operator.equal?(OP_NE)

          # '!=' operator is match when other operator is not '==' operator or version is not match
          # these kinds of comparisons always have a solution
          if is_non_equal_op || is_provider_non_equal_op
            return !is_equal_op && !is_provider_equal_op ||
                version_compare(provider.version, version, '!=', compare_branches)
          end

          # an example for the condition is <= 2.0 & < 1.0
          # these kinds of comparisons always have a solution
          if !is_equal_op && no_equal_op === provider_no_equal_op
            return true
          end

          if version_compare(provider.version, version, self.class.trans_op_int[operator], compare_branches)
            # special case, e.g. require >= 1.0 and provide < 1.0
            # 1.0 >= 1.0 but 1.0 is outside of the provided interval
            if provider.version === version &&
                self.class.trans_op_int[provider.operator] === provider_no_equal_op &&
                self.class.trans_op_int[operator] != no_equal_op
              return false
            end

            return true
          end

          false
        end

        def to_s
          "#{self.class.trans_op_int[operator]} #{version}"
        end

        protected

        def operator
          @operator
        end

        def version
          @version
        end

        def php_version_compare(version1, version2)

          # verify supplied arguments
          unless version1 and version2
            if not version1 and not version2
              return 0
            else
              return version1 ? 1 : -1
            end
          end

          # parse version 1
          if version1[0] == '#'
            v1 = version1.dup.split('.')
          else
            # canonicalize_version
            v1 = version1.strip.gsub(/([\-?_?\+?])/, '.').gsub(/([^\d\.])([^\D\.])/){"#{$1}.#{$2}"}.gsub(/([^\D\.])([^\d\.])/){"#{$1}.#{$2}"}.gsub(/([\.][\.])/, '.').split('.')
          end

          # parse version 2
          if version2[0] == '#'
            v2 = version2.dup.split('.')
          else
            # canonicalize_version
            v2 = version2.strip.gsub(/([\-?_?\+?])/, '.').gsub(/([^\d\.])([^\D\.])/){"#{$1}.#{$2}"}.gsub(/([^\D\.])([^\d\.])/){"#{$1}.#{$2}"}.gsub(/([\.][\.])/, '.').split('.')
          end

          compare = i = 0
          while i < ([v1.length, v2.length].min)

            # continue when both are equal
            next if v1[i].equal?(v2[i])

            i1 = v1[i]
            i2 = v2[i]

            if i1[0] =~ /[[:digit:]]/ && i2[0] =~ /[[:digit:]]/
              # compare element numerically
              l1 = i1.to_i
              l2 = i2.to_i
              compare = l1 - l2 <=> 0
            elsif i1[0] !~ /[[:digit:]]/ && i2[0] !~ /[[:digit:]]/
              # compare element names
              compare = php_forms_compare(i1, i2);
            else
              # mix of names and numbers
              if i1[0] =~ /[[:digit:]]/
                compare = php_forms_compare('#', i2)
              else
                compare = php_forms_compare(i1, '#')
              end
            end

            break unless compare.equal?(0)
            i += 1
          end

          if compare.equal?(0)
            if v2.length > v1.length
              if v2[i][0] =~ /[[:digit:]]/
                compare = -1
              else
                compare = php_version_compare('#', v2[i])
              end
            elsif v2.length < v1.length
              if v1[i][0] =~ /[[:digit:]]/
                compare = 1
              else
                compare = php_version_compare(v1[i], '#')
              end
            end
          end

          compare
        end

        def php_forms_compare(form1, form2)

          special_forms = {
            'dev'   => 0,
            'alpha' => 1,
            'a'     => 1,
            'beta'  => 2,
            'b'     => 2,
            'RC'    => 3,
            'rc'    => 3,
            '#'     => 4,
            'pl'    => 5,
            'p'     => 5,
            nil     => 0,
          }

          f1 = special_forms[form1] ? special_forms[form1] : -1
          f2 = special_forms[form2] ? special_forms[form2] : -1

          f1 - f2 <=> 0
        end
      end
    end
  end
end
