require 'spec_helper'

describe ::Composer::Semver::Constraint::MultiConstraint do

  subject(:multi_constraint) { described_class }
  subject(:constraint) { ::Composer::Semver::Constraint::Constraint }

  context '#matches?' do

    it 'succeeds on matching multi version' do
      version_require_start = constraint.new('>', '1.0')
      version_require_end = constraint.new('<', '1.2')
      version_provide = constraint.new('==', '1.1')

      multi_require = multi_constraint.new([version_require_start, version_require_end])
      expect(multi_require.matches?(version_provide)).to be_truthy
    end

    it 'succeeds on matching multi version provided' do
      version_require_start = constraint.new('>', '1.0')
      version_require_end = constraint.new('<', '1.2')
      version_provide_start = constraint.new('>=', '1.1')
      version_provide_end = constraint.new('<', '2.0')

      multi_require = multi_constraint.new([version_require_start, version_require_end])
      multi_provide = multi_constraint.new([version_provide_start, version_provide_end])
      expect(multi_require.matches?(multi_provide)).to be_truthy
      expect(multi_require.match_specific?(multi_provide)).to be_truthy
    end

    it 'fails on matching multi version' do
      version_require_start = constraint.new('>', '1.0')
      version_require_end = constraint.new('<', '1.2')
      version_provide = constraint.new('==', '1.2')

      multi_require = multi_constraint.new([version_require_start, version_require_end])
      expect(multi_require.matches?(version_provide)).to be_falsey
    end

  end

  context '#match_specific?' do

    it 'succeeds on multi-constraint' do
      version_require_start = constraint.new('>', '1.0')
      version_require_end = constraint.new('<', '1.2')
      version_provide_start = constraint.new('>=', '1.1')
      version_provide_end = constraint.new('<', '2.0')

      multi_require = multi_constraint.new([version_require_start, version_require_end])
      multi_provide = multi_constraint.new([version_provide_start, version_provide_end])
      expect(multi_require.match_specific?(multi_provide)).to be_truthy
    end

    it 'raises argument error on non multi-constraint' do
      version_require_start = constraint.new('>', '1.0')
      version_require_end = constraint.new('<', '1.2')
      version_provide = constraint.new('==', '1.2')

      multi_require = multi_constraint.new([version_require_start, version_require_end])
      expect{ multi_require.match_specific?(version_provide) }.to raise_error(ArgumentError)
    end

  end

  context '#pretty_string' do

    it 'succeeds in get/set' do
      version_require = multi_constraint.allocate

      pretty_string = ''
      expect{ version_require.pretty_string = 'test' }.not_to raise_error
      expect{ pretty_string = version_require.pretty_string }.not_to raise_error
      expect( pretty_string ).to be == 'test'
    end

    it 'succeeds when not set' do
      version_require = multi_constraint.allocate
      pretty_string = ''
      expect{ pretty_string = version_require.pretty_string }.not_to raise_error
      expect( pretty_string ).to be == '[]'
    end

    it 'succeeds on multiple versions' do
      version_require_start = constraint.new('>', '1.0')
      version_require_end = constraint.new('<', '1.2')

      multi_require = multi_constraint.new([version_require_start, version_require_end])
      expect(multi_require.pretty_string ).to be == '[> 1.0 < 1.2]'
    end

  end
end
