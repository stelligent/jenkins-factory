require 'spec_helper'
require 'util'

describe Util do
  describe '#secrets_file_path' do
    it 'returns same path with basename having _secret suffix and same yml extension' do
      actual_result = Util.secrets_file_path 'some/dir/foo.yml'

      expect(actual_result).to eq 'some/dir/foo_secret.yml'
    end
  end


  describe '#transform_keys_to_symbols' do
    it 'returns modified hash with symbols for keys instead of strings' do
      input_hash = {
        'foo' => 1,
        'moo' => 2
      }

      Util.transform_keys_to_symbols input_hash

      expected_result = {
        :foo => 1,
        :moo => 2
      }
      expect(input_hash).to eq expected_result
    end
  end


end