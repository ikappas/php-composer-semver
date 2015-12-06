require 'spec_helper'

describe ::Composer::Semver::Constraint::EmptyConstraint do

  subject(:empty_constraint) { described_class }
  subject(:constraint) { ::Composer::Semver::Constraint::Constraint }

  context '#matches?' do

    [
        { operator: '==', version: '1' },
        { operator: '>=', version: '1' },
        { operator: '>=', version: '2' },
        { operator: '>=', version: '2' },
        { operator: '<=', version: '2' },
        { operator: '>=', version: '1' },
        { operator: '==', version: '2' },
        { operator: '!=', version: '1' },
        { operator: '==', version: 'dev-foo-bar' },
        { operator: '==', version: 'dev-foo-xyz' },
        { operator: '>=', version: 'dev-foo-bar' },
        { operator: '<=', version: 'dev-foo-bar' },
        { operator: '!=', version: 'dev-foo-bar' },
        { operator: '>=', version: 'dev-foo-bar' },
        { operator: '!=', version: 'dev-foo-bar' },

    ].each do |test|
      it "returns true given: #{test[:operator]} #{test[:version]}" do
          version_provide = constraint.new(test[:operator], test[:version])
          expect(empty_constraint.new.matches?(version_provide)).to be_truthy
        end
    end

  end

  context '#match_specific?' do

    [
        { operator: '==', version: '1' },
        { operator: '>=', version: '1' },
        { operator: '>=', version: '2' },
        { operator: '>=', version: '2' },
        { operator: '<=', version: '2' },
        { operator: '>=', version: '1' },
        { operator: '==', version: '2' },
        { operator: '!=', version: '1' },
        { operator: '==', version: 'dev-foo-bar' },
        { operator: '==', version: 'dev-foo-xyz' },
        { operator: '>=', version: 'dev-foo-bar' },
        { operator: '<=', version: 'dev-foo-bar' },
        { operator: '!=', version: 'dev-foo-bar' },
        { operator: '>=', version: 'dev-foo-bar' },
        { operator: '!=', version: 'dev-foo-bar' },

    ].each do |test|
      it "returns true given: #{test[:operator]} #{test[:version]}" do
        version_provide = constraint.new(test[:operator], test[:version])
        expect(empty_constraint.new.match_specific?(version_provide)).to be_truthy
      end
    end

  end

  context '#pretty_string' do

    it 'succeeds in get/set' do
      version_require = empty_constraint.allocate

      pretty_string = ''
      expect{ version_require.pretty_string = 'test' }.not_to raise_error
      expect{ pretty_string = version_require.pretty_string }.not_to raise_error
      expect( pretty_string ).to be == 'test'
    end

    it 'succeeds when not set' do
      version_require = empty_constraint.allocate
      pretty_string = ''
      expect{ pretty_string = version_require.pretty_string }.not_to raise_error
      expect( pretty_string ).to be == '[]'
    end

  end
end
