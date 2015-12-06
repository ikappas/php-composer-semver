require 'spec_helper'

describe ::Composer::Semver::VersionParser do

  subject(:parser) { described_class.new }

  context '#parse_numeric_alias_prefix' do

    [
      { input: '0.x-dev',     expected: '0.' },
      { input: '1.0.x-dev',   expected: '1.0.' },
      { input: '1.x-dev',     expected: '1.' },
      { input: '1.2.x-dev',   expected: '1.2.' },
      { input: '1.2-dev',     expected: '1.2.' },
      { input: '1-dev',       expected: '1.' },
      { input: 'dev-develop', expected: false },
      { input: 'dev-master',  expected: false }

    ].each do |test|
      it "succeeds on #{test[:input]}" do
        expect(parser.parse_numeric_alias_prefix(test[:input])).to be == test[:expected]
      end
    end

  end

  context '#normalize' do

    [
      { name: 'none',                              version: '1.0.0',                 expected: '1.0.0.0' },
      { name: 'none/2',                            version: '1.2.3.4',               expected: '1.2.3.4' },
      { name: 'parses state',                      version: '1.0.0RC1dev',           expected: '1.0.0.0-RC1-dev' },
      { name: 'CI parsing',                        version: '1.0.0-rC15-dev',        expected: '1.0.0.0-RC15-dev' },
      { name: 'delimiters',                        version: '1.0.0.RC.15-dev',       expected: '1.0.0.0-RC15-dev' },
      { name: 'RC uppercase',                      version: '1.0.0-rc1',             expected: '1.0.0.0-RC1' },
      { name: 'patch replace',                     version: '1.0.0.pl3-dev',         expected: '1.0.0.0-patch3-dev' },
      { name: 'forces w.x.y.z',                    version: '1.0-dev',               expected: '1.0.0.0-dev' },
      { name: 'forces w.x.y.z/2',                  version: '0',                     expected: '0.0.0.0' },
      { name: 'parses long',                       version: '10.4.13-beta',          expected: '10.4.13.0-beta' },
      { name: 'parses long/2',                     version: '10.4.13beta2',          expected: '10.4.13.0-beta2' },
      { name: 'parses long/semver',                version: '10.4.13beta.2',         expected: '10.4.13.0-beta2' },
      { name: 'expand shorthand',                  version: '10.4.13-b',             expected: '10.4.13.0-beta' },
      { name: 'expand shorthand/2',                version: '10.4.13-b5',            expected: '10.4.13.0-beta5' },
      { name: 'strips leading v',                  version: 'v1.0.0',                expected: '1.0.0.0' },
      { name: 'parses dates y-m as classical',     version: '2010.01',               expected: '2010.01.0.0' },
      { name: 'parses dates w/ . as classical',    version: '2010.01.02',            expected: '2010.01.02.0' },
      { name: 'parses dates y.m.Y as classical',   version: '2010.1.555',            expected: '2010.1.555.0' },
      { name: 'parses dates y.m.Y/2 as classical', version: '2010.10.200',           expected: '2010.10.200.0' },
      { name: 'strips v/datetime',                 version: 'v20100102',             expected: '20100102' },
      { name: 'parses dates w/ -',                 version: '2010-01-02',            expected: '2010.01.02' },
      { name: 'parses numbers',                    version: '2010-01-02.5',          expected: '2010.01.02.5' },
      { name: 'parses dates y.m.Y',                version: '2010.1.555',            expected: '2010.1.555.0' },
      { name: 'parses datetime',                   version: '20100102-203040',       expected: '20100102.203040' },
      { name: 'parses dt+number',                  version: '20100102203040-10',     expected: '20100102203040.10' },
      { name: 'parses dt+patch',                   version: '20100102-203040-p1',    expected: '20100102.203040-patch1' },
      { name: 'parses master',                     version: 'dev-master',            expected: '9999999-dev' },
      { name: 'parses trunk',                      version: 'dev-trunk',             expected: '9999999-dev' },
      { name: 'parses branches',                   version: '1.x-dev',               expected: '1.9999999.9999999.9999999-dev' },
      { name: 'parses arbitrary',                  version: 'dev-feature-foo',       expected: 'dev-feature-foo' },
      { name: 'parses arbitrary/2',                version: 'DEV-FOOBAR',            expected: 'dev-FOOBAR' },
      { name: 'parses arbitrary/3',                version: 'dev-feature/foo',       expected: 'dev-feature/foo' },
      { name: 'ignores aliases',                   version: 'dev-master as 1.0.0',   expected: '9999999-dev' },
      { name: 'semver metadata',                   version: 'dev-master+foo.bar',    expected: '9999999-dev' },
      { name: 'semver metadata/2',                 version: '1.0.0-beta.5+foo',      expected: '1.0.0.0-beta5' },
      { name: 'semver metadata/3',                 version: '1.0.0+foo',             expected: '1.0.0.0' },
      { name: 'semver metadata/4',                 version: '1.0.0-alpha.3.1+foo',   expected: '1.0.0.0-alpha3.1' },
      { name: 'semver metadata/5',                 version: '1.0.0-alpha2.1+foo',    expected: '1.0.0.0-alpha2.1' },
      { name: 'semver metadata/6',                 version: '1.0.0-alpha-2.1-3+foo', expected: '1.0.0.0-alpha2.1-3' },

      #{ name: 'not supported for BC 'semver metadata/7', data: { version: '1.0.0-0.3.7', expected: '1.0.0.0-0.3.7' },
      #{ name: 'not supported for BC 'semver metadata/8', data: { version: '1.0.0-x.7.z.92', expected: '1.0.0.0-x.7.z.92' },
      { name: 'metadata w/ alias',                 version: '1.0.0+foo as 2.0',      expected: '1.0.0.0' },

    ].each do |test|
      it "succeeds on #{test[:name]}" do
        expect(parser.normalize(test[:version])).to be == test[:expected]
      end
    end

    [
      { name: 'nil',               version: nil,             expected: ArgumentError },
      { name: 'empty ',            version: '',              expected: ArgumentError },
      { name: 'invalid chars',     version: 'a',             expected: ArgumentError },
      { name: 'invalid type',      version: '1.0.0-meh',     expected: ArgumentError },
      { name: 'too many bits',     version: '1.0.0.0.0',     expected: ArgumentError },
      { name: 'non-dev arbitrary', version: 'feature-foo',   expected: ArgumentError },
      { name: 'metadata w/ space', version: '1.0.0+foo bar', expected: ArgumentError }

    ].each do |test|
      it "raises error on #{test[:name]}" do
        expect { parser.normalize(test[:version]) }.to raise_error(test[:expected])
      end
    end

    it 'adds extra message on alias failure' do
      expect { parser.normalize('1.0.0-meh as 1.0.0-meh') }.to raise_error( ArgumentError, /^Invalid version string ".*" in ".*", the alias must.*$/)
    end

    it 'adds extra message on alias source failure' do
      expect { parser.normalize('1.0.0-meh as foo') }.to raise_error( ArgumentError, /^Invalid version string ".*" in ".*", the alias source.*$/)
    end

  end

  context '#nomalize_stability' do

    [
      { stability: 'STABLE', expected: 'stable' },
      { stability: 'stable', expected: 'stable' },
      { stability: 'RC',     expected: 'RC' },
      { stability: 'rc',     expected: 'RC' },
      { stability: 'BETA',   expected: 'beta' },
      { stability: 'beta',   expected: 'beta' },
      { stability: 'ALPHA',  expected: 'alpha' },
      { stability: 'alpha',  expected: 'alpha' },
      { stability: 'DEV',    expected: 'dev' },
      { stability: 'dev',    expected: 'dev' },

    ].each do |test|
      it "succeeds on #{test[:stability]}" do
        expect( parser.class.normalize_stability(test[:stability])).to be == test[:expected]
      end
    end

    [
      { name: 'nil',   stability: nil,             error: ArgumentError },
      { name: 'array', stability: ['test'],        error: TypeError },
      { name: 'hash',  stability: { test: 'test' }, error: TypeError },

    ].each do |test|
      it "raises error on #{test[:name]}" do
        expect { parser.class.normalize_stability(test[:stability]) }.to raise_error(test[:error])
      end
    end

  end

  context '#nomalize_branch' do

    [
      { name: 'parsing x',             branch: 'v1.x',      expected: '1.9999999.9999999.9999999-dev' },
      { name: 'parsing *',             branch: 'v1.*',      expected: '1.9999999.9999999.9999999-dev' },
      { name: 'parsing digits',        branch: 'v1.0',      expected: '1.0.9999999.9999999-dev' },
      { name: 'parsing digits/2',      branch: '2.0',       expected: '2.0.9999999.9999999-dev' },
      { name: 'parsing long x',        branch: 'v1.0.x',    expected: '1.0.9999999.9999999-dev' },
      { name: 'parsing long *',        branch: 'v1.0.3.*',  expected: '1.0.3.9999999-dev' },
      { name: 'parsing long digits',   branch: 'v2.4.0',    expected: '2.4.0.9999999-dev' },
      { name: 'parsing long digits/2', branch: '2.4.4',     expected: '2.4.4.9999999-dev' },
      { name: 'parsing master',        branch: 'master',    expected: '9999999-dev' },
      { name: 'parsing trunk',         branch: 'trunk',     expected: '9999999-dev' },
      { name: 'parsing arbitrary',     branch: 'feature-a', expected: 'dev-feature-a' },
      { name: 'parsing arbitrary/2',   branch: 'FOOBAR',    expected: 'dev-FOOBAR' }

    ].each do |test|
      it "succeeds on #{test[:name]}" do
        expect( parser.normalize_branch(test[:branch])).to be == test[:expected]
      end
    end

    [
      { name: 'nil',   branch: nil,              error: ArgumentError },
      { name: 'array', branch: ['test'],         error: TypeError },
      { name: 'hash',  branch: { test: 'test' }, error: TypeError },

    ].each do |test|
      it "raises error on #{test[:name]}" do
        expect { parser.normalize_branch(test[:branch]) }.to raise_error(test[:error])
      end
    end

  end

  context '#parse_constraints' do

    it 'ignores stability flag' do
      expected = ::Composer::Semver::Constraint::Constraint.new('=', '1.0.0.0')
      expect( String(parser.parse_constraints('1.0@dev')) ).to be == String(expected)
    end

    it 'ignores reference on dev version' do
      expected = ::Composer::Semver::Constraint::Constraint.new('=', '1.0.9999999.9999999-dev')
      expect( String(parser.parse_constraints('1.0.x-dev#abcd123')) ).to be == String(expected)
      expect( String(parser.parse_constraints('1.0.x-dev#trunk/@123')) ).to be == String(expected)
    end

    it 'raises error on bad reference' do
      expect { String(parser.parse_constraints('1.0#abcd123')) }.to raise_error(ArgumentError)
      expect { String(parser.parse_constraints('1.0#trunk/@123')) }.to raise_error(ArgumentError)
    end

    it 'nudges ruby devs towards the path of righteousness' do
      expect { String(parser.parse_constraints('~>1.2')) }.to raise_error(ArgumentError)
    end

    [
      { name: 'matching any',           input: '*',                   constraint: nil },
      { name: 'matching any/2',         input: '*.*',                 constraint: nil },
      { name: 'matching any/2v',        input: 'v*.*',                constraint: nil },
      { name: 'matching any/3',         input: '*.x.*',               constraint: nil },
      { name: 'matching any/4',         input: 'x.X.x.*',             constraint: nil },
      { name: 'not equal',              input: '<>1.0.0',             constraint: { operator: '<>', version:  '1.0.0.0' } },
      { name: 'not equal/2',            input: '!=1.0.0',             constraint: { operator: '!=', version:  '1.0.0.0' } },
      { name: 'greater than',           input: '>1.0.0',              constraint: { operator: '>',  version: '1.0.0.0' } },
      { name: 'lesser than',            input: '<1.2.3.4',            constraint: { operator: '<',  version: '1.2.3.4-dev' } },
      { name: 'less/eq than',           input: '<=1.2.3',             constraint: { operator: '<=', version:  '1.2.3.0' } },
      { name: 'great/eq than',          input: '>=1.2.3',             constraint: { operator: '>=', version:  '1.2.3.0-dev' } },
      { name: 'equals',                 input: '=1.2.3',              constraint: { operator: '=',  version: '1.2.3.0' } },
      { name: 'double equals',          input: '==1.2.3',             constraint: { operator: '=',  version: '1.2.3.0' } },
      { name: 'no op means eq',         input: '1.2.3',               constraint: { operator: '=',  version: '1.2.3.0' } },
      { name: 'completes version',      input: '=1.0',                constraint: { operator: '=',  version: '1.0.0.0' } },
      { name: 'shorthand beta',         input: '1.2.3b5',             constraint: { operator: '=',  version: '1.2.3.0-beta5' } },
      { name: 'shorthand alpha',        input: '1.2.3a1',             constraint: { operator: '=',  version: '1.2.3.0-alpha1' } },
      { name: 'shorthand patch',        input: '1.2.3p1234',          constraint: { operator: '=',  version: '1.2.3.0-patch1234' } },
      { name: 'shorthand patch/2',      input: '1.2.3pl1234',         constraint: { operator: '=',  version: '1.2.3.0-patch1234' } },
      { name: 'accepting spaces',       input: '>= 1.2.3',            constraint: { operator: '>=', version:  '1.2.3.0-dev' } },
      { name: 'accepting spaces/2',     input: '< 1.2.3',             constraint: { operator: '<',  version: '1.2.3.0-dev' } },
      { name: 'accepting spaces/3',     input: '> 1.2.3',             constraint: { operator: '>',  version: '1.2.3.0' } },
      { name: 'accepting master',       input: '>=dev-master',        constraint: { operator: '>=', version:  '9999999-dev' } },
      { name: 'accepting master/2',     input: 'dev-master',          constraint: { operator: '=',  version: '9999999-dev' } },
      { name: 'accepting arbitrary',    input: 'dev-feature-a',       constraint: { operator: '=',  version: 'dev-feature-a' } },
      { name: 'regression #550',        input: 'dev-some-fix',        constraint: { operator: '=',  version: 'dev-some-fix' } },
      { name: 'regression #935',        input: 'dev-CAPS',            constraint: { operator: '=',  version: 'dev-CAPS' } },
      { name: 'ignores aliases',        input: 'dev-master as 1.0.0', constraint: { operator: '=',  version: '9999999-dev' } },
      { name: 'lesser than override',   input: '<1.2.3.4-stable',     constraint: { operator: '<',  version: '1.2.3.4' } },
      { name: 'great/eq than override', input: '>=1.2.3.4-stable',    constraint: { operator: '>=', version:  '1.2.3.4' } },

    ].each do |test|
      it "succeeds on #{test[:name]}" do
        if test[:constraint]
          expected = ::Composer::Semver::Constraint::Constraint.new(test[:constraint][:operator], test[:constraint][:version])
        else
          expected = ::Composer::Semver::Constraint::EmptyConstraint.new
        end
        expect( String(parser.parse_constraints(test[:input])) ).to be == String(expected)
      end
    end

    [

      { input: 'v2.*',    min: { operator:'>=', version: '2.0.0.0-dev' },  max: { operator: '<', version: '3.0.0.0-dev' } },
      { input: '2.*.*',   min: { operator:'>=', version: '2.0.0.0-dev' },  max: { operator: '<', version: '3.0.0.0-dev' } },
      { input: '20.*',    min: { operator:'>=', version: '20.0.0.0-dev' }, max: { operator: '<', version: '21.0.0.0-dev' } },
      { input: '20.*.*',  min: { operator:'>=', version: '20.0.0.0-dev' }, max: { operator: '<', version: '21.0.0.0-dev' } },
      { input: '2.0.*',   min: { operator:'>=', version: '2.0.0.0-dev' },  max: { operator: '<', version: '2.1.0.0-dev' } },
      { input: '2.x',     min: { operator:'>=', version: '2.0.0.0-dev' },  max: { operator: '<', version: '3.0.0.0-dev' } },
      { input: '2.x.x',   min: { operator:'>=', version: '2.0.0.0-dev' },  max: { operator: '<', version: '3.0.0.0-dev' } },
      { input: '2.2.x',   min: { operator:'>=', version: '2.2.0.0-dev' },  max: { operator: '<', version: '2.3.0.0-dev' } },
      { input: '2.10.X',  min: { operator:'>=', version: '2.10.0.0-dev' }, max: { operator: '<', version: '2.11.0.0-dev' } },
      { input: '2.1.3.*', min: { operator:'>=', version: '2.1.3.0-dev' },  max: { operator: '<', version: '2.1.4.0-dev' } },
      { input: '0.*',     min: nil,                                        max: { operator: '<', version: '1.0.0.0-dev' } },
      { input: '0.*.*',   min: nil,                                        max: { operator: '<', version: '1.0.0.0-dev' } },
      { input: '0.x',     min: nil,                                        max: { operator: '<', version: '1.0.0.0-dev' } },
      { input: '0.x.x',   min: nil,                                        max: { operator: '<', version: '1.0.0.0-dev' } },

    ].each do |test|
      it "succeeds on parsing wildcard #{test[:input]}" do
        if test[:min]
        min = ::Composer::Semver::Constraint::Constraint.new(test[:min][:operator], test[:min][:version])
        max = ::Composer::Semver::Constraint::Constraint.new(test[:max][:operator], test[:max][:version])
        expected = String(::Composer::Semver::Constraint::MultiConstraint.new([min, max]))
        else
          expected = String(::Composer::Semver::Constraint::Constraint.new(test[:max][:operator], test[:max][:version]))
        end
        expect( outcome = String(parser.parse_constraints(test[:input])) ).to be == expected, failure_message(test[:input], expected, outcome)
      end
    end

    [
      { input: '~v1',           min: { operator: '>=', version: '1.0.0.0-dev' },    max: { operator: '<', version: '2.0.0.0-dev' } },
      { input: '~1.0',          min: { operator: '>=', version: '1.0.0.0-dev' },    max: { operator: '<', version: '2.0.0.0-dev' } },
      { input: '~1.0.0',        min: { operator: '>=', version: '1.0.0.0-dev' },    max: { operator: '<', version: '1.1.0.0-dev' } },
      { input: '~1.2',          min: { operator: '>=', version: '1.2.0.0-dev' },    max: { operator: '<', version: '2.0.0.0-dev' } },
      { input: '~1.2.3',        min: { operator: '>=', version: '1.2.3.0-dev' },    max: { operator: '<', version: '1.3.0.0-dev' } },
      { input: '~1.2.3.4',      min: { operator: '>=', version: '1.2.3.4-dev' },    max: { operator: '<', version: '1.2.4.0-dev' } },
      { input: '~1.2-beta',     min: { operator: '>=', version: '1.2.0.0-beta' },   max: { operator: '<', version: '2.0.0.0-dev' } },
      { input: '~1.2-b2',       min: { operator: '>=', version: '1.2.0.0-beta2' },  max: { operator: '<', version: '2.0.0.0-dev' } },
      { input: '~1.2-BETA2',    min: { operator: '>=', version: '1.2.0.0-beta2' },  max: { operator: '<', version: '2.0.0.0-dev' } },
      { input: '~1.2.2-dev',    min: { operator: '>=', version: '1.2.2.0-dev' },    max: { operator: '<', version: '1.3.0.0-dev' } },
      { input: '~1.2.2-stable', min: { operator: '>=', version: '1.2.2.0-stable' }, max: { operator: '<', version: '1.3.0.0-dev' } },

    ].each do |test|
      it "succeeds on parsing tilde #{test[:input]}" do
        min = ::Composer::Semver::Constraint::Constraint.new(test[:min][:operator], test[:min][:version])
        max = ::Composer::Semver::Constraint::Constraint.new(test[:max][:operator], test[:max][:version])
        expected = String(::Composer::Semver::Constraint::MultiConstraint.new([min, max]))
        expect( outcome = String(parser.parse_constraints(test[:input])) ).to be == expected, failure_message(test[:input], expected, outcome)
      end
    end

    [
      { input: '^v1',           min: { operator: '>=', version: '1.0.0.0-dev' },   max: { operator: '<', version: '2.0.0.0-dev' } },
      { input: '^0',            min: { operator: '>=', version: '0.0.0.0-dev' },   max: { operator: '<', version: '1.0.0.0-dev' } },
      { input: '^0.0',          min: { operator: '>=', version: '0.0.0.0-dev' },   max: { operator: '<', version: '0.1.0.0-dev' } },
      { input: '^1.2',          min: { operator: '>=', version: '1.2.0.0-dev' },   max: { operator: '<', version: '2.0.0.0-dev' } },
      { input: '^1.2.3-beta.2', min: { operator: '>=', version: '1.2.3.0-beta2' }, max: { operator: '<', version: '2.0.0.0-dev' } },
      { input: '^1.2.3.4',      min: { operator: '>=', version: '1.2.3.4-dev' },   max: { operator: '<', version: '2.0.0.0-dev' } },
      { input: '^1.2.3',        min: { operator: '>=', version: '1.2.3.0-dev' },   max: { operator: '<', version: '2.0.0.0-dev' } },
      { input: '^0.2.3',        min: { operator: '>=', version: '0.2.3.0-dev' },   max: { operator: '<', version: '0.3.0.0-dev' } },
      { input: '^0.2',          min: { operator: '>=', version: '0.2.0.0-dev' },   max: { operator: '<', version: '0.3.0.0-dev' } },
      { input: '^0.2.0',        min: { operator: '>=', version: '0.2.0.0-dev' },   max: { operator: '<', version: '0.3.0.0-dev' } },
      { input: '^0.0.3',        min: { operator: '>=', version: '0.0.3.0-dev' },   max: { operator: '<', version: '0.0.4.0-dev' } },
      { input: '^0.0.3-alpha',  min: { operator: '>=', version: '0.0.3.0-alpha' }, max: { operator: '<', version: '0.0.4.0-dev' } },
      { input: '^0.0.3-dev',    min: { operator: '>=', version: '0.0.3.0-dev' },   max: { operator: '<', version: '0.0.4.0-dev' } },

    ].each do |test|
      it "succeeds on parsing caret #{test[:input]}" do
        min = ::Composer::Semver::Constraint::Constraint.new(test[:min][:operator], test[:min][:version])
        max = ::Composer::Semver::Constraint::Constraint.new(test[:max][:operator], test[:max][:version])
        expected = String(::Composer::Semver::Constraint::MultiConstraint.new([min, max]))
        expect( outcome = String(parser.parse_constraints(test[:input])) ).to be == expected, failure_message(test[:input], expected, outcome)
      end
    end

    [
      { input: 'v1 - v2',              min: { operator: '>=', version: '1.0.0.0-dev' },   max: { operator: '<',  version: '3.0.0.0-dev' } },
      { input: '1.2.3 - 2.3.4.5',      min: { operator: '>=', version: '1.2.3.0-dev' },   max: { operator: '<=', version: '2.3.4.5' } },
      { input: '1.2-beta - 2.3',       min: { operator: '>=', version: '1.2.0.0-beta' },  max: { operator: '<',  version: '2.4.0.0-dev' } },
      { input: '1.2-beta - 2.3-dev',   min: { operator: '>=', version: '1.2.0.0-beta' },  max: { operator: '<=', version: '2.3.0.0-dev' } },
      { input: '1.2-RC - 2.3.1',       min: { operator: '>=', version: '1.2.0.0-RC' },    max: { operator: '<=', version: '2.3.1.0' } },
      { input: '1.2.3-alpha - 2.3-RC', min: { operator: '>=', version: '1.2.3.0-alpha' }, max: { operator: '<=', version: '2.3.0.0-RC' } },
      { input: '1 - 2.0',              min: { operator: '>=', version: '1.0.0.0-dev' },   max: { operator: '<',  version: '2.1.0.0-dev' } },
      { input: '1 - 2.1',              min: { operator: '>=', version: '1.0.0.0-dev' },   max: { operator: '<',  version: '2.2.0.0-dev' } },
      { input: '1.2 - 2.1.0',          min: { operator: '>=', version: '1.2.0.0-dev' },   max: { operator: '<=', version: '2.1.0.0' } },
      { input: '1.3 - 2.1.3',          min: { operator: '>=', version: '1.3.0.0-dev' },   max: { operator: '<=', version: '2.1.3.0' } },

    ].each do |test|
      it "succeeds on parsing hyphen #{test[:input]}" do
        min = ::Composer::Semver::Constraint::Constraint.new(test[:min][:operator], test[:min][:version])
        max = ::Composer::Semver::Constraint::Constraint.new(test[:max][:operator], test[:max][:version])
        expected = String(::Composer::Semver::Constraint::MultiConstraint.new([min, max]))
        expect( outcome = String(parser.parse_constraints(test[:input])) ).to be == expected, failure_message(test[:input], expected, outcome)
      end
    end

    [
      { input: '>2.0,<=3.0' },
      { input: '>2.0 <=3.0' },
      { input: '>2.0  <=3.0' },
      { input: '>2.0, <=3.0' },
      { input: '>2.0 ,<=3.0' },
      { input: '>2.0 , <=3.0' },
      { input: '>2.0   , <=3.0' },
      { input: '> 2.0   <=  3.0' },
      { input: '> 2.0  ,  <=  3.0' },
      { input: '  > 2.0  ,  <=  3.0 ' }

    ].each do |test|
      it "succeeds on parsing multi #{test[:input]}" do
        first  = ::Composer::Semver::Constraint::Constraint.new('>', '2.0.0.0')
        second = ::Composer::Semver::Constraint::Constraint.new('<=', '3.0.0.0')
        multi  = ::Composer::Semver::Constraint::MultiConstraint.new([first, second])
        expect( String(parser.parse_constraints(test[:input])) ).to be == String(multi)
      end
    end

    it 'succeeds on parsing multi constraints with stability suffix' do
      first  = ::Composer::Semver::Constraint::Constraint.new('>=', '1.1.0.0-alpha4')
      second = ::Composer::Semver::Constraint::Constraint.new('<', '1.2.9999999.9999999-dev')
      multi  = ::Composer::Semver::Constraint::MultiConstraint.new([first, second])
      expect( String(parser.parse_constraints('>=1.1.0-alpha4,<1.2.x-dev')) ).to be == String(multi)

      first  = ::Composer::Semver::Constraint::Constraint.new('>=', '1.1.0.0-alpha4')
      second = ::Composer::Semver::Constraint::Constraint.new('<', '1.2.0.0-beta2')
      multi  = ::Composer::Semver::Constraint::MultiConstraint.new([first, second])
      expect( String(parser.parse_constraints('>=1.1.0-alpha4,<1.2-beta2')) ).to be == String(multi)
    end

    it 'succeeds on parsing multi disjunctive having priority over conjunctive' do
      [
        { constraint: '>2.0,<2.0.5 | >2.0.6' },
        { constraint: '>2.0,<2.0.5 || >2.0.6' },
        { constraint: '> 2.0 , <2.0.5 | >  2.0.6' }

      ].each do |setup|
        first  = ::Composer::Semver::Constraint::Constraint.new('>', '2.0.0.0')
        second = ::Composer::Semver::Constraint::Constraint.new('<', '2.0.5.0-dev')
        third  = ::Composer::Semver::Constraint::Constraint.new('>', '2.0.6.0')
        multi1 = ::Composer::Semver::Constraint::MultiConstraint.new([first, second])
        multi2 = ::Composer::Semver::Constraint::MultiConstraint.new([multi1, third], false)
        expect( String(parser.parse_constraints(setup[:constraint])) ).to be == String(multi2)
      end
    end

    it 'succeeds on parsing multi with stabilities' do
      first  = ::Composer::Semver::Constraint::Constraint.new('>', '2.0.0.0')
      second = ::Composer::Semver::Constraint::Constraint.new('<=', '3.0.0.0-dev')
      multi  = ::Composer::Semver::Constraint::MultiConstraint.new([first, second])
      expect( String(parser.parse_constraints('>2.0@stable,<=3.0@dev')) ).to be == String(multi)
    end

    [
      { name: 'nil',              input: nil,              error: ArgumentError },
      { name: 'array',            input: ['test'],         error: TypeError },
      { name: 'hash',             input: { test: 'test' }, error: TypeError },
      { name: 'empty',            input: '',               error: ArgumentError },
      { name: 'invalid version',  input: '1.0.0-meh',      error: ArgumentError },
      { name: 'operator abuse',   input: '>2.0,,<=3.0',    error: ArgumentError },
      { name: 'operator abuse/2', input: '>2.0 ,, <=3.0',  error: ArgumentError },
      { name: 'operator abuse/3', input: '>2.0 ||| <=3.0', error: ArgumentError }

    ].each do |test|
      it "raises error on #{test[:name]} constraint" do
        expect { parser.parse_constraints(test[:input]) }.to raise_error(test[:error])
      end
    end

  end

  context '#parse_stability' do

    [
      { version: '1',                     expected: 'stable' },
      { version: '1.0',                   expected: 'stable' },
      { version: '3.2.1',                 expected: 'stable' },
      { version: 'v3.2.1',                expected: 'stable' },
      { version: 'v2.0.x-dev',            expected: 'dev' },
      { version: 'v2.0.x-dev#abc123',     expected: 'dev' },
      { version: 'v2.0.x-dev#trunk/@123', expected: 'dev' },
      { version: '3.0-RC2',               expected: 'RC' },
      { version: 'dev-master',            expected: 'dev' },
      { version: '3.1.2-dev',             expected: 'dev' },
      { version: '3.1.2-p1',              expected: 'stable' },
      { version: '3.1.2-pl2',             expected: 'stable' },
      { version: '3.1.2-patch',           expected: 'stable' },
      { version: '3.1.2-alpha5',          expected: 'alpha' },
      { version: '3.1.2-beta',            expected: 'beta' },
      { version: '2.0B1',                 expected: 'beta' },
      { version: '1.2.0a1',               expected: 'alpha' },
      { version: '1.2_a1',                expected: 'alpha' },
      { version: '2.0.0rc1',              expected: 'RC' },

    ].each do |test|
      it "succeeds on #{test[:version]}" do
        expect( parser.class.parse_stability(test[:version]) ).to be == test[:expected]
      end
    end

    [
        { name: 'nil',   version: nil,             error: ArgumentError },
        { name: 'array', version: ['test'],        error: TypeError },
        { name: 'hash',  version: { test: 'test' }, error: TypeError },

    ].each do |test|
      it "raises error on #{test[:name]}" do
        expect { parser.class.parse_stability(test[:version]) }.to raise_error(test[:error])
      end
    end
  end
end
