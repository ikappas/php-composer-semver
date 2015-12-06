require 'spec_helper'

describe ::Composer::Semver::Constraint::Base do

  subject(:constraint_class) { described_class }
  subject(:empty_constraint_class) { ::Composer::Semver::Constraint::EmptyConstraint }

  context '#pretty_string' do

    it 'succeeds in get/set' do
      pretty_string = ''
      constraint = constraint_class.new
      expect{ constraint.pretty_string = 'test' }.not_to raise_error
      expect{ pretty_string = constraint.pretty_string }.not_to raise_error
      expect( pretty_string ).to be == 'test'
    end

    it 'succeeds when not set' do
      pretty_string = ''
      constraint = constraint_class.new

      expect{ pretty_string = constraint.pretty_string }.not_to raise_error
      expect( pretty_string ).to match /^#<Composer::Semver::Constraint::Base:(.*)>$/
    end

  end

  context '#matches?' do

    it 'raises argument error on non self or subclasses' do
      constraint = constraint_class.new
      expect{ constraint.matches?('') }.to raise_error(ArgumentError)
    end

    it 'calls match_specific? on self when provider is same class' do

      constraint = constraint_class.allocate
      allow(constraint).to receive(:match_specific?).and_return( true )

      provider = constraint_class.allocate
      expect( constraint.matches?(provider) ).to be_truthy

    end

    it 'calls match_specific? on provider when subclass' do

      constraint = constraint_class.allocate
      provider = empty_constraint_class.allocate
      expect( constraint.matches?(provider) ).to be_truthy

    end

  end

  context '#match_specific?' do

    it 'raises not implemented error' do
      constraint = constraint_class.new
      expect{ constraint.match_specific?('') }.to raise_error(NotImplementedError)
    end

  end


end
