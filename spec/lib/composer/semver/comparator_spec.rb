require_relative '../../../spec_helper'

describe ::Composer::Semver::Comparator do

  subject(:comparator) { described_class }

  context '#greater_than?' do
    it 'returns true on v1 > v2' do
      expect(comparator.greater_than?('1.25.0', '1.24.0')).to be_truthy
    end
    it 'returns false on v1 = v2' do
      expect(comparator.greater_than?('1.25.0', '1.25.0')).to be_falsey
    end
    it 'returns false on v1 < v2' do
      expect(comparator.greater_than?('1.25.0', '1.26.0')).to be_falsey
    end
  end

  context '#greater_than_or_equal_to?' do
    it 'returns true on v1 > v2' do
      expect(comparator.greater_than_or_equal_to?('1.25.0', '1.24.0')).to be_truthy
    end
    it 'returns true on v1 = v2' do
      expect(comparator.greater_than_or_equal_to?('1.25.0', '1.25.0')).to be_truthy
    end
    it 'returns false on v1 < v2' do
      expect(comparator.greater_than_or_equal_to?('1.25.0', '1.26.0')).to be_falsey
    end
  end

  context '#less_than?' do
    it 'returns false on v1 > v2' do
      expect(comparator.less_than?('1.25.0', '1.24.0')).to be_falsey
    end
    it 'returns false on v1 = v2' do
      expect(comparator.less_than?('1.25.0', '1.25.0')).to be_falsey
    end
    it 'returns true on v1 < v2' do
      expect(comparator.less_than?('1.25.0', '1.26.0')).to be_truthy
    end
  end

  context '#less_than_or_equal_to?' do
    it 'returns false on v1 > v2' do
      expect(comparator.less_than_or_equal_to?('1.25.0', '1.24.0')).to be_falsey
    end
    it 'returns true on v1 = v2' do
      expect(comparator.less_than_or_equal_to?('1.25.0', '1.25.0')).to be_truthy
    end
    it 'returns true on v1 < v2' do
      expect(comparator.less_than_or_equal_to?('1.25.0', '1.26.0')).to be_truthy
    end
  end

  context '#equal_to?' do
    it 'returns false on v1 > v2' do
      expect(comparator.equal_to?('1.25.0', '1.24.0')).to be_falsey
    end
    it 'returns true on v1 = v2' do
      expect(comparator.equal_to?('1.25.0', '1.25.0')).to be_truthy
    end
    it 'returns false on v1 < v2' do
      expect(comparator.equal_to?('1.25.0', '1.26.0')).to be_falsey
    end
  end

  context '#not_equal_to?' do
    it 'returns true on v1 > v2' do
      expect(comparator.not_equal_to?('1.25.0', '1.24.0')).to be_truthy
    end
    it 'returns false on v1 = v2' do
      expect(comparator.not_equal_to?('1.25.0', '1.25.0')).to be_falsey
    end
    it 'returns true on v1 < v2' do
      expect(comparator.not_equal_to?('1.25.0', '1.26.0')).to be_truthy
    end
  end

  context '#compare' do

    [
      { version_1: '1.25.0', operator: '>', version_2: '1.24.0', expected: true },
      { version_1: '1.25.0', operator: '>', version_2: '1.25.0', expected: false },
      { version_1: '1.25.0', operator: '>', version_2: '1.26.0', expected: false },

      { version_1: '1.25.0', operator: '>=', version_2: '1.24.0', expected: true },
      { version_1: '1.25.0', operator: '>=', version_2: '1.25.0', expected: true },
      { version_1: '1.25.0', operator: '>=', version_2: '1.26.0', expected: false },

      { version_1: '1.25.0', operator: '<', version_2: '1.24.0', expected: false },
      { version_1: '1.25.0', operator: '<', version_2: '1.25.0', expected: false },
      { version_1: '1.25.0', operator: '<', version_2: '1.26.0', expected: true },
      { version_1: '1.25.0-beta2.1', operator: '<', version_2: '1.25.0-b.3', expected: true },
      { version_1: '1.25.0-b2.1', operator: '<', version_2: '1.25.0beta.3', expected: true },
      { version_1: '1.25.0-b-2.1', operator: '<', version_2: '1.25.0-rc', expected: true },

      { version_1: '1.25.0', operator: '<=', version_2: '1.24.0', expected: false },
      { version_1: '1.25.0', operator: '<=', version_2: '1.25.0', expected: true },
      { version_1: '1.25.0', operator: '<=', version_2: '1.26.0', expected: true },

      { version_1: '1.25.0', operator: '==', version_2: '1.24.0', expected: false },
      { version_1: '1.25.0', operator: '==', version_2: '1.25.0', expected: true },
      { version_1: '1.25.0', operator: '==', version_2: '1.26.0', expected: false },
      { version_1: '1.25.0-beta2.1', operator: '==', version_2: '1.25.0-b.2.1', expected: true },
      { version_1: '1.25.0beta2.1', operator: '==', version_2: '1.25.0-b2.1', expected: true },

      { version_1: '1.25.0', operator: '=', version_2: '1.24.0', expected: false },
      { version_1: '1.25.0', operator: '=', version_2: '1.25.0', expected: true },
      { version_1: '1.25.0', operator: '=', version_2: '1.26.0', expected: false },

      { version_1: '1.25.0', operator: '!=', version_2: '1.24.0', expected: true },
      { version_1: '1.25.0', operator: '!=', version_2: '1.25.0', expected: false },
      { version_1: '1.25.0', operator: '!=', version_2: '1.26.0', expected: true },

      { version_1: '1.25.0', operator: '<>', version_2: '1.24.0', expected: true },
      { version_1: '1.25.0', operator: '<>', version_2: '1.25.0', expected: false },
      { version_1: '1.25.0', operator: '<>', version_2: '1.26.0', expected: true }

    ].each do |test|
      it "returns #{test[:expected]} on #{test[:version_1]} #{test[:operator]} #{test[:version_2]}" do
        expect(comparator.compare?(test[:version_1], test[:operator], test[:version_2])).to be == test[:expected]
      end
    end
  end
end
