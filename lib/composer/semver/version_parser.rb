#
# This library was ported to ruby from php source code files.
# Original Source: Composer\Semver\VersionParser.php
#
# (c) Composer <https://github.com/composer>
#
# For the full copyright and license information, please view the LICENSE
# file that was distributed with this source code.
#

module Composer
  module Semver

    # Version Parser
    #
    # PHP Authors:
    # Jordi Boggiano <j.boggiano@seld.be>
    #
    # Ruby Authors:
    # Ioannis Kappas <ikappas@devworks.gr>
    class VersionParser

      def self.modifier_regex
        @modifier_regex ||= '[._-]?(?:(stable|beta|b|RC|alpha|a|patch|pl|p)((?:[.-]?\d+)*+)?)?([.-]?dev)?'.freeze
      end

      def self.stabilities
        @stabilities ||= %w{stable RC beta alpha dev}.freeze
      end

      # Returns the stability of a version
      #
      # @param version string The version to parse for stability
      #
      # @return string The version's stability
      def self.parse_stability(version)

        raise ArgumentError,
              'version must be specified' if version.nil?

        raise TypeError,
              'version must be of type String' unless version.is_a?(String)

        version.gsub!(/#.+$/i, '')

        # match dev stability
        if version.start_with?('dev-') or version.end_with?('-dev')
          return 'dev'
        end

        /#{self.modifier_regex}$/i.match(version.downcase) do |matches|

          if !matches[3].nil? && !matches[3].empty?
            return 'dev'
          end

          if !matches[1].nil? && !matches[1].empty?

            if matches[1] === 'beta' || matches[1] === 'b'
              return 'beta'
            end

            if matches[1] === 'alpha' || matches[1] === 'a'
              return 'alpha'
            end

            if matches[1] === 'rc'
              return 'RC'
            end

          end

        end

        'stable'
      end

      # Normalize the specified stability
      #
      # @param stability string The stability to normalize.
      #
      # @return string
      def self.normalize_stability(stability)

        # verify supplied arguments
        raise ArgumentError,
              'stability must be specified' unless stability

        raise TypeError,
              'stability must be of type String' unless stability.is_a?(String)

        stability = stability.downcase
        stability === 'rc' ? 'RC' : stability
      end

      # Normalizes a version string to be able to perform comparisons on it
      #
      # Params:
      # @param version string The version string to normalize
      # @param full_version string Optional. The complete version string to
      #                            give more context
      #
      # @throws InvalidVersionStringError
      #
      # @return string The normalized version string.
      def normalize(version, full_version = nil)

        # verify supplied arguments
        raise ArgumentError,
              'version must be specified' if version.nil?

        raise TypeError,
              'version must be of type String' unless version.is_a?(String)

        # trim the version
        version.strip!

        # set the full_version unless specified
        full_version = version if full_version.nil?

        # set default index
        index = 0

        # strip off aliasing
        /^([^,\s]+) +as +([^,\s]+)$/.match(version) do |matches|
          version = matches[1]
        end

        # strip off build metadata
        /^([^,\s+]+)\+[^\s]+$/.match(version) do |matches|
          version = matches[1]
        end

        # match master-like branches
        if /^(?:dev-)?(?:master|trunk|default)$/i.match(version)
          return '9999999-dev'
        end

        # match dev- prefix versioning
        if version.downcase.start_with?('dev-')
          return "dev-#{version[4..version.size]}"
        end

        # match classical versioning
        if (matches = /^v?(\d{1,5})(\.\d+)?(\.\d+)?(\.\d+)?#{self.class.modifier_regex}$/i.match(version))
          version = ''
          matches.to_a[1..4].each do |c|
            version += c ? c : '.0'
          end
          index = 5
        # match data(time) based versioning
        elsif (matches = /^v?(\d{4}(?:[.:-]?\d{2}){1,6}(?:[.:-]?\d{1,3})?)#{self.class.modifier_regex}$/i.match(version))
          version = matches[1].gsub(/\D/, '.')
          index = 2
        end

        # add version modifiers if a version was matched
        if index > 0

          if !matches[index].nil? && !matches[index].empty?

            if matches[index] === 'stable'
              return version
            end

            stability = expand_stability(matches[index])
            version << "-#{stability}"
            if !matches[index + 1].nil? && !matches[index + 1].empty?
              version << matches[index + 1].gsub(/^[.-]+/, '')
            end

          end

          if !matches[index + 2].nil? && !matches[index + 2].empty?
            version << '-dev'
          end

          return version
        end

        # match dev branches
        /(.*?)[.-]?dev$/i.match(version) do |match|
          begin
            return normalize_branch(match[1])
          rescue
            #skip
          end
        end

        extra_message = ''
        if / +as +#{Regexp.escape(version)}$/.match(full_version)
          extra_message = " in \"#{full_version}\", the alias must be an exact version"
        elsif /^#{Regexp.escape(version)} +as +/.match(full_version)
          extra_message = " in \"#{full_version}\", the alias source must be an exact version, if it is a branch name you should prefix it with dev-"
        end

        raise ArgumentError,
              "Invalid version string \"#{version}\"#{extra_message}"
      end

      # Extract numeric prefix from alias, if it is in numeric format, suitable for version comparison.
      #
      # @param branch string The branch name to parse (e.g. 2.1.x-dev)
      #
      # @return string|false The numeric prefix if present (e.g. 2.1.) or false
      def parse_numeric_alias_prefix(branch)
        /^(?<version>(\d+\.)*\d+)(?:\.x)?-dev$/i.match(branch) do |matches|
          return "#{matches['version']}."
        end
        false
      end

      # Normalizes a branch name to be able to perform comparisons on it
      #
      # @param name string The branch name to normalize
      #
      # @return string The normalized branch name
      def normalize_branch(name)

        # verify supplied arguments
        raise ArgumentError,
              'name must be specified' unless name

        raise TypeError,
              'name must be of type String' unless name.is_a?(String)

        raise ArgumentError,
              'name string must not be empty' if name.empty?

        name.strip!
        if %w{master trunk default}.include?(name)
          normalize(name)
        elsif (matches = /^v?(\d+)(\.(?:\d+|[xX*]))?(\.(?:\d+|[xX*]))?(\.(?:\d+|[xX*]))?$/i.match(name))
          version = ''
          matches.captures.each { |match| version << (match != nil ? match.tr('*', 'x').tr('X', 'x') : '.x') }
          "#{version.gsub('x', '9999999')}-dev"
        else
          "dev-#{name}"
        end
      end

      # Parses a constraint string into MultiConstraint and/or Constraint objects.
      #
      # @param constraints string The constraints to parse.
      #
      # @return ::Composer::Semver::Constraint::Base
      def parse_constraints(constraints)

        # verify supplied arguments
        raise ArgumentError,
              'version must be specified' unless constraints

        raise TypeError,
              'version must be of type String' unless constraints.is_a?(String)

        raise ArgumentError,
              'version string must not be empty' if constraints.empty?

        pretty_constraint = constraints

        # match stabilities constraints
        /^([^,\s]*?)@(#{self.class.stabilities.join('|')})$/i.match(constraints) do |match|
          constraints = match[1].nil? || match[1].empty? ? '*' : match[1]
        end

        # match dev constraints
        /^(dev-[^,\s@]+?|[^,\s@]+?\.x-dev)#.+$/i.match(constraints) do |match|
          constraints = match[1]
        end

        or_groups = []
        or_constraints = constraints.strip.split(/\s*\|\|?\s*/)
        or_constraints.each do |or_constraint|

          and_constraints = or_constraint.split(/(?<!^|as|[=>< ,]) *(?<!-)[, ](?!-) *(?!,|as|$)/)

          if and_constraints.length > 1
            constraint_objects = []
            and_constraints.each do |and_constraint|
              parse_constraint(and_constraint).each {|parsed_constraint| constraint_objects << parsed_constraint }
            end
          else
            constraint_objects = parse_constraint(and_constraints[0])
          end

          if constraint_objects.length.equal?(1)
            constraint = constraint_objects[0]
          else
            constraint = ::Composer::Semver::Constraint::MultiConstraint.new(constraint_objects)
          end

          or_groups << constraint
        end

        if or_groups.length.equal?(1)
          constraint = or_groups[0]
        else
          constraint = ::Composer::Semver::Constraint::MultiConstraint.new(or_groups, false)
        end

        constraint.pretty_string = pretty_constraint

        constraint
      end


      # PRIVATE METHODS
      private

      # Parse a single constraint
      #
      # @param constraint string The constraint to parse.
      #
      # @raises UnexpectedValueError
      #
      # @return array
      def parse_constraint(constraint)

        error = nil
        stabilities = ::Composer::Semver::VersionParser::stabilities.join('|')
        stability_modifier = ''
        /^([^,\s]+?)@(#{stabilities})$/i.match(constraint) do |match|
          constraint = match[1]
          if match[2] != 'stable'
            stability_modifier = match[2]
          end
        end

        if /^v?[xX*](\.[xX*])*$/i.match(constraint)
          return [
              Composer::Semver::Constraint::EmptyConstraint.new
          ]
        end

        version_regex = 'v?(\d+)(?:\.(\d+))?(?:\.(\d+))?(?:\.(\d+))?' + self.class.modifier_regex + '(?:\+[^\s]+)?'

        # Helper method to check presence
        present = lambda {|v| !v.nil? && !v.empty? }

        # Tilde Range
        #
        # Like wildcard constraints, un-suffixed tilde constraints say that they must be greater than the previous
        # version, to ensure that unstable instances of the current version are allowed. However, if a stability
        # suffix is added to the constraint, then a >= match on the current version is used instead.
        /^~>?#{version_regex}$/i.match(constraint) do |matches|

          if constraint.start_with?('~>')
            raise ArgumentError,
                  "Could not parse version constraint #{constraint}:
                  Invalid operator \"~>\", you probably meant to use the \"~\" operator"
          end

          # Work out which position in the version we are operating at
          if present.call(matches[4])
            position = 4
          elsif present.call(matches[3])
            position = 3
          elsif present.call(matches[2])
            position = 2
          else
            position = 1
          end

          # Calculate the stability suffix
          stability_suffix = ''
          unless matches[5].nil? || matches[5].empty?
            stability_suffix << "-#{expand_stability(matches[5])}"
            unless matches[6].nil? || matches[6].empty?
              stability_suffix << matches[6]
            end
          end

          unless matches[7].nil? || matches[7].empty?
            stability_suffix << '-dev'
          end

          if stability_suffix.empty?
            stability_suffix = '-dev'
          end

          low_version = manipulate_version_string(matches, position, 0) + stability_suffix
          lower_bound = Composer::Semver::Constraint::Constraint.new('>=', low_version)

          # For upper bound, we increment the position of one more significance,
          # but high_position = 0 would be illegal
          high_position = [1, position - 1].max
          high_version = manipulate_version_string(matches, high_position, 1) + '-dev'
          upper_bound = Composer::Semver::Constraint::Constraint.new('<', high_version)

          return [
              lower_bound,
              upper_bound
          ]
        end

        # Caret Range
        #
        # Allows changes that do not modify the left-most non-zero digit in the [major, minor, patch] tuple.
        # In other words, this allows patch and minor updates for versions 1.0.0 and above, patch updates for
        # versions 0.X >=0.1.0, and no updates for versions 0.0.X
        /^\^#{version_regex}($)/i.match(constraint) do |matches|

          # Work out which position in the version we are operating at
          if matches[1] != '0' || matches[2].nil? || matches[2] === ''
            position = 1
          elsif matches[2] != '0' || matches[3].nil? || matches[3] === ''
            position = 2
          else
            position = 3
          end

          # Calculate the stability suffix
          stability_suffix = ''
          if (matches[5].nil? || matches[5].empty?) && (matches[7].nil? || matches[7].empty?)
            stability_suffix << '-dev'
          end

          low_pretty = "#{constraint}#{stability_suffix}"
          low_version = normalize(low_pretty[1..low_pretty.length - 1])
          lower_bound = Composer::Semver::Constraint::Constraint.new('>=', low_version)

          # For upper bound, we increment the position of one more significance,
          # but high_position = 0 would be illegal
          high_version = manipulate_version_string(matches, position, 1) + '-dev'
          upper_bound = Composer::Semver::Constraint::Constraint.new('<', high_version)

          return [
              lower_bound,
              upper_bound
          ]
        end

        # X Range
        #
        # Any of X, x, or * may be used to "stand in" for one of the numeric values in the [major, minor, patch] tuple.
        # A partial version range is treated as an X-Range, so the special character is in fact optional.
        /^v?(\d+)(?:\.(\d+))?(?:\.(\d+))?(?:\.[xX*])+$/.match(constraint) do |matches|

          if present.call(matches[3])
            position = 3
          elsif present.call(matches[2])
            position = 2
          else
            position = 1
          end

          low_version = manipulate_version_string(matches, position) + '-dev'
          high_version = manipulate_version_string(matches, position, 1) + '-dev'

          if low_version === '0.0.0.0-dev'
            return [
                ::Composer::Semver::Constraint::Constraint.new('<', high_version)
            ]
          end

          return [
              ::Composer::Semver::Constraint::Constraint.new('>=', low_version),
              ::Composer::Semver::Constraint::Constraint.new('<', high_version)
          ]
        end

        # Hyphen Range
        #
        # Specifies an inclusive set. If a partial version is provided as the first version in the inclusive range,
        # then the missing pieces are replaced with zeroes. If a partial version is provided as the second version in
        # the inclusive range, then all versions that start with the supplied parts of the tuple are accepted, but
        # nothing that would be greater than the provided tuple parts.
        #
        # We don't use named groups since ruby will return only the named matches and not the rest
        # /^(?<from>#{version_regex}) +- +(?<to>#{version_regex})($)/i.match(constraint) do |matches|
        /^(#{version_regex}) +- +(#{version_regex})($)/i.match(constraint) do |matches|

          match_from = matches[1]
          match_to = matches[9]

          # calculate the stability suffix
          if (matches[6].nil? || matches[6].empty?) && (matches[8].nil? || matches[8].empty?)
            low_stability_suffix = '-dev'
          else
            low_stability_suffix = ''
          end

          low_version = normalize(match_from)
          lower_bound = ::Composer::Semver::Constraint::Constraint.new('>=', low_version + low_stability_suffix)

          not_zero_or_empty = lambda {|x| (x == 0 || x == '0') ? false : (x.nil? || x.empty?) }

          if (!not_zero_or_empty.call(matches[11]) && !not_zero_or_empty.call(matches[12])) || present.call(matches[14]) || present.call(matches[16])
            high_version = normalize(match_to)
            upper_bound = ::Composer::Semver::Constraint::Constraint.new('<=', high_version)
          else
            high_match = ['', matches[10], matches[11], matches[12], matches[13]]
            high_version = manipulate_version_string(high_match, ( not_zero_or_empty.call(matches[11]) ? 1 : 2), 1) + '-dev'
            upper_bound = ::Composer::Semver::Constraint::Constraint.new('<', high_version)
          end

          return [
              lower_bound,
              upper_bound
          ]
        end

        # Basic Comparators
        /^(<>|!=|>=?|<=?|==?)?\s*(.*)/.match(constraint) do |matches|
          begin

            version = normalize(matches[2])

            if !stability_modifier.empty? && self.class.parse_stability(version) === 'stable'
              version << "-#{stability_modifier}"
            elsif matches[1] === '<' || matches[1] === '>='
              unless /-#{self.class.modifier_regex}$/.match(matches[2].downcase)
                unless matches[2].start_with?('dev-')
                  version << '-dev'
                end
              end
            end
            operator = matches[1].nil? ? '=' : matches[1]
            return [
                ::Composer::Semver::Constraint::Constraint.new(operator, version)
            ]
          rescue => e
            error = e
            # ignore
          end
        end

        message = "Could not parse version constraint #{constraint}"
        message << ": #{error.message}" unless error.nil?
        raise ArgumentError, message
      end

      # Increment, decrement, or simply pad a version number.
      # Support function for {@link parse_constraint()}
      #
      # Params:
      # +matches+ Array with version parts in array indexes 1,2,3,4
      # +position+ Integer 1,2,3,4 - which segment of the version to decrement
      # +increment+ Integer
      # +pad+ String The string to pad version parts after position
      #
      # Returns:
      # string The new version
      def manipulate_version_string(matches, position, increment = 0, pad = '0')
        component = !matches.kind_of?(Array) ? matches.to_a : matches
        4.downto(1).each do |i|
          if i > position
            component[i] = pad
          elsif i === position && increment
            component[i] = component[i].to_i + increment
            # If component[i] was 0, carry the decrement
            if component[i] < 0
              component[i] = pad
              position -= 1

              # Return nil on a carry overflow
              return nil if i === 1
            end
          end
        end
        "#{component[1]}.#{component[2]}.#{component[3]}.#{component[4]}"
      end

      def expand_stability(stability)
        stability = stability.downcase
        case stability
        when 'a'
          'alpha'
        when 'b'
          'beta'
        when 'p', 'pl'
          'patch'
        when 'rc'
          'RC'
        else
          stability
        end
      end
    end
  end
end
