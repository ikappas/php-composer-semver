require_relative '../../../../spec_helper'

describe ::Composer::Semver::Constraint::Constraint do

  subject(:constraint) { described_class }

  context '#matches?' do
    [
      { require: { operator: '==', version: '1' }, provide: { operator: '==', version: '1' } },
      { require: { operator: '>=', version: '1' }, provide: { operator: '>=', version: '2' } },
      { require: { operator: '>=', version: '2' }, provide: { operator: '>=', version: '1' } },
      { require: { operator: '>=', version: '2' }, provide: { operator: '>',  version: '1' } },
      { require: { operator: '<=', version: '2' }, provide: { operator: '>=', version: '1' } },
      { require: { operator: '>=', version: '1' }, provide: { operator: '<=', version: '2' } },
      { require: { operator: '==', version: '2' }, provide: { operator: '>=', version: '2' } },
      { require: { operator: '!=', version: '1' }, provide: { operator: '!=', version: '1' } },
      { require: { operator: '!=', version: '1' }, provide: { operator: '==', version: '2' } },
      { require: { operator: '!=', version: '1' }, provide: { operator: '<',  version: '1' } },
      { require: { operator: '!=', version: '1' }, provide: { operator: '<=', version: '1' } },
      { require: { operator: '!=', version: '1' }, provide: { operator: '>',  version: '1' } },
      { require: { operator: '!=', version: '1' }, provide: { operator: '>=', version: '1' } },
      { require: { operator: '==', version: 'dev-foo-bar' }, provide: { operator: '==', version: 'dev-foo-bar' } },
      { require: { operator: '==', version: 'dev-foo-xyz' }, provide: { operator: '==', version: 'dev-foo-xyz' } },
      { require: { operator: '>=', version: 'dev-foo-bar' }, provide: { operator: '>=', version: 'dev-foo-xyz' } },
      { require: { operator: '<=', version: 'dev-foo-bar' }, provide: { operator: '<',  version: 'dev-foo-xyz' } },
      { require: { operator: '!=', version: 'dev-foo-bar' }, provide: { operator: '<',  version: 'dev-foo-xyz' } },
      { require: { operator: '>=', version: 'dev-foo-bar' }, provide: { operator: '!=', version: 'dev-foo-bar' } },
      { require: { operator: '!=', version: 'dev-foo-bar' }, provide: { operator: '!=', version: 'dev-foo-xyz' } },

    ].each do |test|
      it "returns true on requirement: #{test[:require][:operator]} #{test[:require][:version]} given: #{test[:provide][:operator]} #{test[:provide][:version]}" do

        version_require = constraint.new(test[:require][:operator], test[:require][:version])
        version_provide = constraint.new(test[:provide][:operator], test[:provide][:version])

        expect(version_require.matches?(version_provide)).to be_truthy
      end
    end

    [
      { require: { operator: '==', version: '1' }, provide: { operator: '==', version: '2' } },
      { require: { operator: '>=', version: '2' }, provide: { operator: '<=', version: '1' } },
      { require: { operator: '>=', version: '2' }, provide: { operator: '<',  version: '2' } },
      { require: { operator: '<=', version: '2' }, provide: { operator: '>',  version: '2' } },
      { require: { operator: '>',  version: '2' }, provide: { operator: '<=', version: '2' } },
      { require: { operator: '<=', version: '1' }, provide: { operator: '>=', version: '2' } },
      { require: { operator: '>=', version: '2' }, provide: { operator: '<=', version: '1' } },
      { require: { operator: '==', version: '2' }, provide: { operator: '<',  version: '2' } },
      { require: { operator: '!=', version: '1' }, provide: { operator: '==', version: '1' } },
      { require: { operator: '==', version: '1' }, provide: { operator: '!=', version: '1' } },
      { require: { operator: '==', version: 'dev-foo-dist' }, provide: { operator: '==', version: 'dev-foo-zist' } },
      { require: { operator: '==', version: 'dev-foo-bist' }, provide: { operator: '==', version: 'dev-foo-aist' } },
      { require: { operator: '<=', version: 'dev-foo-bist' }, provide: { operator: '>=', version: 'dev-foo-aist' } },
      { require: { operator: '>=', version: 'dev-foo-bist' }, provide: { operator: '<',  version: 'dev-foo-aist' } },
      { require: { operator: '<',  version: '0.12' }, provide: { operator: '==', version: 'dev-foo' } }, # branches are not comparable
      { require: { operator: '>',  version: '0.12' }, provide: { operator: '==', version: 'dev-foo' } }, # branches are not comparable

    ].each do |test|
      it "returns false on requirement: #{test[:require][:operator]} #{test[:require][:version]} given: #{test[:provide][:operator]} #{test[:provide][:version]}" do
        version_require = constraint.new(test[:require][:operator], test[:require][:version])
        version_provide = constraint.new(test[:provide][:operator], test[:provide][:version])

        expect(version_require.matches?(version_provide)).to be_falsey
      end
    end


    it 'inverse matching other multi-constraint' do

      version_require = constraint.new('>', '1.0.0')

      multi_constraint = ::Composer::Semver::Constraint::MultiConstraint.allocate
      allow(multi_constraint).to receive(:matches?).and_return( true )

      expect(version_require.matches?(multi_constraint)).to be_truthy
    end

    it 'inverse matching other empty-constraint' do
      version_require = constraint.new('>', '1.0.0')

      empty_constraint = ::Composer::Semver::Constraint::EmptyConstraint.allocate
      allow(empty_constraint).to receive(:matches?).and_return( true )

      expect(version_require.matches?(empty_constraint)).to be_truthy
    end

    it 'test comparable matches' do

      version_require = constraint.new('>', '0.12.0')
      version_provide = constraint.new('==', 'dev-foo')

      expect(version_require.matches?(version_provide)).to be_falsey
      expect(version_require.match_specific?(version_provide, true)).to be_falsey

      version_require = constraint.new('<', '0.12.0')
      version_provide = constraint.new('==', 'dev-foo')

      expect(version_require.matches?(version_provide)).to be_falsey
      expect(version_require.match_specific?(version_provide, true)).to be_truthy

    end

    [
        { name: 'nil',   version: nil,              error: ArgumentError },
        { name: 'array', version: ['test'],         error: ArgumentError },
        { name: 'hash',  version: { test: 'test' }, error: ArgumentError },

    ].each do |test|
      it "raises error on #{test[:name]}" do
        version_require = constraint.new('>', '0.12')
        expect { version_require.matches?(test[:version]) }.to raise_error(test[:error])
      end
    end

  end

  context '#initialize' do

    [
      { name: 'nil',         operator: nil,              error: ArgumentError },
      { name: 'array',       operator: ['test'],         error: ArgumentError },
      { name: 'hash',        operator: { test: 'test' }, error: ArgumentError },
      { name: 'empty',       operator: '',               error: ArgumentError },
      { name: 'arbitrary/1', operator: 'invalid',        error: ArgumentError },
      { name: 'arbitrary/2', operator: '!',              error: ArgumentError },
      { name: 'arbitrary/3', operator: 'equals',         error: ArgumentError },

    ].each do |test|
      it "raises error on #{test[:name]}" do
        expect { constraint.new(test[:operator], '1.2.3') }.to raise_error(test[:error])
      end
    end

  end

  context '#pretty_string' do

    it 'succeeds in get/set' do
      version_require = constraint.allocate

      pretty_string = ''
      expect{ version_require.pretty_string = 'test' }.not_to raise_error
      expect{ pretty_string = version_require.pretty_string }.not_to raise_error
      expect( pretty_string ).to be == 'test'
    end

    it 'succeeds when not set' do
      version_require = constraint.new('>', '1.0.0')
      pretty_string = ''
      expect{ pretty_string = version_require.pretty_string }.not_to raise_error
      expect( pretty_string ).to be == '> 1.0.0'
    end

  end

  context '#version_compare' do

    it 'matches first version when second version nil' do
      allocated_constraint = constraint.allocate
      expect(allocated_constraint.version_compare('1.0.0', nil, '>')).to be_truthy
      expect(allocated_constraint.version_compare('1.0.0', nil, '<')).to be_falsey
      expect(allocated_constraint.version_compare('1.0.0', nil, '==')).to be_falsey
      expect(allocated_constraint.version_compare('1.0.0', nil, '>=')).to be_truthy
      expect(allocated_constraint.version_compare('1.0.0', nil, '<=')).to be_falsey
      expect(allocated_constraint.version_compare('1.0.0', nil, '<>')).to be_truthy
    end

    it 'matches second version when first version nil' do
      allocated_constraint = constraint.allocate
      expect(allocated_constraint.version_compare( nil, '1.0.0', '>')).to be_falsey
      expect(allocated_constraint.version_compare( nil, '1.0.0', '<')).to be_truthy
      expect(allocated_constraint.version_compare( nil, '1.0.0', '==')).to be_falsey
      expect(allocated_constraint.version_compare( nil, '1.0.0', '>=')).to be_falsey
      expect(allocated_constraint.version_compare( nil, '1.0.0', '<=')).to be_truthy
      expect(allocated_constraint.version_compare( nil, '1.0.0', '<>')).to be_truthy
    end

    it 'matches none when both versions nil' do
      allocated_constraint = constraint.allocate
      expect(allocated_constraint.version_compare( nil, nil, '>')).to be_falsey
      expect(allocated_constraint.version_compare( nil, nil, '<')).to be_falsey
      expect(allocated_constraint.version_compare( nil, nil, '==')).to be_truthy
      expect(allocated_constraint.version_compare( nil, nil, '>=')).to be_truthy
      expect(allocated_constraint.version_compare( nil, nil, '<=')).to be_truthy
      expect(allocated_constraint.version_compare( nil, nil, '<>')).to be_falsey
    end

    it 'not matches same version with unequal components 1 < 1.0 < 1.0' do

      allocated_constraint = constraint.allocate
      expect(allocated_constraint.version_compare( '1.0.0.0', '1.0.0', '==')).to be_falsey
      expect(allocated_constraint.version_compare( '1.0.0', '1.0.0.0', '==')).to be_falsey

    end

    it 'return false when operator nil' do

      allocated_constraint = constraint.allocate
      expect(allocated_constraint.version_compare( '1.0.0.0', '1.0.0', nil)).to be_falsey

    end

    it 'parses when mix of names and numbers' do

      allocated_constraint = constraint.allocate
      expect(allocated_constraint.version_compare( '1.0.0.0', '1.0.0alpha', '>')).to be_truthy
      expect(allocated_constraint.version_compare( '1.0.0alpha', '1.0.0.0', '<')).to be_truthy

    end

  #
  #   tests = lambda do
  #
  #     special_forms = %w{dev a alpha b beta RC pl}
  #     prefixes = ['', '.', '-']
  #     suffixes = ['', '.']
  #
  #     # special_forms = %w{dev a a1 alpha2 a.3 alpha.4 .a5 .alpha6 -alpha7 b b1 beta2 b.3 beta.4 .b5 .beta6 RC RC1 RC.2 .RC3 .RC.4 pl pl1 pl.2 .pl3 .pl.4}
  #     i1 = i2 = 0
  #     matrix = []
  #     special_forms.each do |f1|
  #       special_forms.each do |f2|
  #         prefixes.each do |p1|
  #           prefixes.each do |p2|
  #             suffixes.each do |s1|
  #               suffixes.each do |s2|
  #                 if f1[0] != f2[0]
  #                   if i1 < i2
  #                     op = '<'
  #                     not_op = '>'
  #                   elsif i1 > i2
  #                     op = '>'
  #                     not_op = '<'
  #                   else
  #                     op = '=='
  #                     not_op = '<>'
  #                   end
  #                   matrix.push({ version_1: '1.0' +  p1 + f1 + s1, version_2: '1.0' +  p2 + f2 + s2, operator: op, expected: true })
  #                   matrix.push({ version_1: '1.0' +  p2 + f2 + s2, version_2: '1.0' +  p1 + f1 + s1, operator: not_op, expected: true })
  #                 else
  #                   op = '=='
  #                   not_op = '<>'
  #
  #                   matrix.push({ version_1: '1.0' +  p1 + f1 + s1, version_2: '1.0' +  p2 + f2 + s2, operator: op, expected: true })
  #                   matrix.push({ version_1: '1.0' +  p2 + f2 + s2, version_2: '1.0' +  p1 + f1 + s1, operator: not_op, expected: false })
  #                 end
  #               end
  #             end
  #           end
  #         end
  #         i2 += 1
  #       end
  #       i2 = 0
  #       i1 += 1
  #     end
  #     return matrix
  #   end
  #
  #   tests.call().each do |test|
  #     constraint = constraint.allocate
  #     it "returns #{test[:expected]} on special form #{test[:version_1]} #{test[:operator]} #{test[:version_2]}" do
  #       expect(constraint.version_compare(test[:version_1], test[:version_2], test[:operator])).to be test[:expected]
  #     end
  #   end
  end
  
end
