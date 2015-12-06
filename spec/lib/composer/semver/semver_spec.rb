require 'spec_helper'

describe ::Composer::Semver::Semver do

  subject(:semver) { described_class }

  context '#satisfies?' do

    [
      { version: '1.2.3', constraint: '1.0.0 - 2.0.0' },
      { version: '1.2.3', constraint: '^1.2.3+build' },
      { version: '1.3.0', constraint: '^1.2.3+build' },
      { version: '2.4.3-alpha', constraint: '1.2.3+asdf - 2.4.3+asdf' },
      { version: '1.3.0-beta', constraint: '>1.2' },
      { version: '1.2.3-beta', constraint: '<=1.2.3' },
      { version: '1.2.3-beta', constraint: '^1.2.3' },
      { version: '1.2.3', constraint: '1.2.3+asdf - 2.4.3+asdf' },
      { version: '1.0.0', constraint: '1.0.0' },
      { version: '1.2.3', constraint: '*' },
      { version: 'v1.2.3', constraint: '*' },
      { version: '1.0.0', constraint: '>=1.0.0' },
      { version: '1.0.1', constraint: '>=1.0.0' },
      { version: '1.1.0', constraint: '>=1.0.0' },
      { version: '1.0.1', constraint: '>1.0.0' },
      { version: '1.1.0', constraint: '>1.0.0' },
      { version: '2.0.0', constraint: '<=2.0.0' },
      { version: '1.9999.9999', constraint: '<=2.0.0' },
      { version: '0.2.9', constraint: '<=2.0.0' },
      { version: '1.9999.9999', constraint: '<2.0.0' },
      { version: '0.2.9', constraint: '<2.0.0' },
      { version: '1.0.0', constraint: '>= 1.0.0' },
      { version: '1.0.1', constraint: '>=  1.0.0' },
      { version: '1.1.0', constraint: '>=   1.0.0' },
      { version: '1.0.1', constraint: '> 1.0.0' },
      { version: '1.1.0', constraint: '>  1.0.0' },
      { version: '2.0.0', constraint: '<=   2.0.0' },
      { version: '1.9999.9999', constraint: '<= 2.0.0' },
      { version: '0.2.9', constraint: '<=  2.0.0' },
      { version: '1.9999.9999', constraint: '<    2.0.0' },
      { version: '0.2.9', constraint: "<\t2.0.0" },
      { version: 'v0.1.97', constraint: '>=0.1.97' },
      { version: '0.1.97', constraint: '>=0.1.97' },
      { version: '1.2.4', constraint: '0.1.20 || 1.2.4' },
      { version: '0.0.0', constraint: '>=0.2.3 || <0.0.1' },
      { version: '0.2.3', constraint: '>=0.2.3 || <0.0.1' },
      { version: '0.2.4', constraint: '>=0.2.3 || <0.0.1' },
      { version: '2.1.3', constraint: '2.x.x' },
      { version: '1.2.3', constraint: '1.2.x' },
      { version: '2.1.3', constraint: '1.2.x || 2.x' },
      { version: '1.2.3', constraint: '1.2.x || 2.x' },
      { version: '1.2.3', constraint: 'x' },
      { version: '2.1.3', constraint: '2.*.*' },
      { version: '1.2.3', constraint: '1.2.*' },
      { version: '2.1.3', constraint: '1.2.* || 2.*' },
      { version: '1.2.3', constraint: '1.2.* || 2.*' },
      { version: '1.2.3', constraint: '*' },
      { version: '2.9.0', constraint: '~2.4' }, # >=2.4.0 <3.0.0
      { version: '2.4.5', constraint: '~2.4' },
      { version: '1.2.3', constraint: '~1' },   # >=1.0.0 <2.0.0
      { version: '1.4.7', constraint: '~1.0' }, # >=1.0.0 <2.0.0
      { version: '1.0.0', constraint: '>=1' },
      { version: '1.0.0', constraint: '>= 1' },
      { version: '1.2.8', constraint: '>1.2' }, # >1.2.0
      { version: '1.1.1', constraint: '<1.2' }, # <1.2.0
      { version: '1.1.1', constraint: '< 1.2' },
      { version: '1.2.3', constraint: '~1.2.1 >=1.2.3' },
      { version: '1.2.3', constraint: '~1.2.1 =1.2.3' },
      { version: '1.2.3', constraint: '~1.2.1 1.2.3' },
      { version: '1.2.3', constraint: '~1.2.1 >=1.2.3 1.2.3' },
      { version: '1.2.3', constraint: '~1.2.1 1.2.3 >=1.2.3' },
      { version: '1.2.3', constraint: '~1.2.1 1.2.3' },
      { version: '1.2.3', constraint: '>=1.2.1 1.2.3' },
      { version: '1.2.3', constraint: '1.2.3 >=1.2.1' },
      { version: '1.2.3', constraint: '>=1.2.3 >=1.2.1' },
      { version: '1.2.3', constraint: '>=1.2.1 >=1.2.3' },
      { version: '1.2.8', constraint: '>=1.2' },
      { version: '1.8.1', constraint: '^1.2.3' },
      { version: '0.1.2', constraint: '^0.1.2' },
      { version: '0.1.2', constraint: '^0.1' },
      { version: '1.4.2', constraint: '^1.2' },
      { version: '1.4.2', constraint: '^1.2 ^1' },
      { version: '0.0.1-beta', constraint: '^0.0.1-alpha' }

    ].each do |test|
      it "succeeds on positive #{test[:version]}" do
        expect(semver.satisfies?(test[:version], test[:constraint])).to be_truthy
      end
    end

    [
      { version: '2.2.3',       constraint: '1.0.0 - 2.0.0' },
      { version: '2.0.0',       constraint: '^1.2.3+build' },
      { version: '1.2.0',       constraint: '^1.2.3+build' },
      { version: '1.0.0beta',   constraint: '1' },
      { version: '1.0.0beta',   constraint: '<1' },
      { version: '1.0.0beta',   constraint: '< 1' },
      { version: '1.0.1',       constraint: '1.0.0' },
      { version: '0.0.0',       constraint: '>=1.0.0' },
      { version: '0.0.1',       constraint: '>=1.0.0' },
      { version: '0.1.0',       constraint: '>=1.0.0' },
      { version: '0.0.1',       constraint: '>1.0.0' },
      { version: '0.1.0',       constraint: '>1.0.0' },
      { version: '3.0.0',       constraint: '<=2.0.0' },
      { version: '2.9999.9999', constraint: '<=2.0.0' },
      { version: '2.2.9',       constraint: '<=2.0.0' },
      { version: '2.9999.9999', constraint: '<2.0.0' },
      { version: '2.2.9',       constraint: '<2.0.0' },
      { version: 'v0.1.93',     constraint: '>=0.1.97' },
      { version: '0.1.93',      constraint: '>=0.1.97' },
      { version: '1.2.3',       constraint: '0.1.20 || 1.2.4' },
      { version: '0.0.3',       constraint: '>=0.2.3 || <0.0.1' },
      { version: '0.2.2',       constraint: '>=0.2.3 || <0.0.1' },
      { version: '1.1.3',       constraint: '2.x.x' },
      { version: '3.1.3',       constraint: '2.x.x' },
      { version: '1.3.3',       constraint: '1.2.x' },
      { version: '3.1.3',       constraint: '1.2.x || 2.x' },
      { version: '1.1.3',       constraint: '1.2.x || 2.x' },
      { version: '1.1.3',       constraint: '2.*.*' },
      { version: '3.1.3',       constraint: '2.*.*' },
      { version: '1.3.3',       constraint: '1.2.*' },
      { version: '3.1.3',       constraint: '1.2.* || 2.*' },
      { version: '1.1.3',       constraint: '1.2.* || 2.*' },
      { version: '1.1.2',       constraint: '2' },
      { version: '2.4.1',       constraint: '2.3' },
      { version: '3.0.0',       constraint: '~2.4' }, # >=2.4.0 <3.0.0
      { version: '2.3.9',       constraint: '~2.4' },
      { version: '0.2.3',       constraint: '~1' },   # >=1.0.0 <2.0.0
      { version: '1.0.0',       constraint: '<1' },
      { version: '1.1.1',       constraint: '>=1.2' },
      { version: '2.0.0beta',   constraint: '1' },
      { version: '0.5.4-alpha', constraint: '~v0.5.4-beta' },
      { version: '1.2.3-beta',  constraint: '<1.2.3' },
      { version: '2.0.0-alpha', constraint: '^1.2.3' },
      { version: '1.2.2',       constraint: '^1.2.3' },
      { version: '1.1.9',       constraint: '^1.2' }

    ].each do |test|
      it "succeeds on negative #{test[:version]}" do
        expect(semver.satisfies?(test[:version], test[:constraint])).to be_falsey
      end
    end
  end

  context '#satisfied_by' do
    [
      {
        constraint: '~1.0',
        versions: %w{1.0 1.2 1.9999.9999 2.0 2.1 0.9999.9999},
        expected: %w{1.0 1.2 1.9999.9999},
      },
      {
        constraint: '>1.0 <3.0 || >=4.0',
        versions: %w{1.0 1.1 2.9999.9999 3.0 3.1 3.9999.9999 4.0 4.1},
        expected: %w{1.1 2.9999.9999 4.0 4.1},
      },
      {
        constraint: '^0.2.0',
        versions: %w{0.1.1 0.1.9999 0.2.0 0.2.1 0.3.0},
        expected: %w{0.2.0 0.2.1},
      }

    ].each do |test|
      it "succeeds on #{test[:constraint]}" do
        expect(semver.satisfied_by(test[:versions], test[:constraint])).to be == test[:expected]
      end
    end
  end

  context '#sort' do

    test = {
      versions: %w{1.0 0.1 0.1 3.2.1 2.4.0-alpha 2.4.0},
      sorted: %w{0.1 0.1 1.0 2.4.0-alpha 2.4.0 3.2.1},
      rsorted: %w{3.2.1 2.4.0 2.4.0-alpha 1.0 0.1 0.1}
    }

    it 'succeeds on ASC' do
      expect(semver.sort(test[:versions])).to be == test[:sorted]
    end

    it 'succeeds on DESC' do
      expect(semver.rsort(test[:versions])).to be == test[:rsorted]
    end

  end
end
