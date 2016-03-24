require 'spec_helper'
require 'base_jenkins_ami'

describe BaseJenkinsAmi do
  before(:all) do
    @base_jenkins_ami = BaseJenkinsAmi.new
  end

  context 'region is valid' do
    it 'returns an ami' do
      ENV['AWS_REGION'] = 'us-west-2'
      ami_id = @base_jenkins_ami.discover_base_ami
      expect(ami_id).to match /ami-[0-9a-f]{8}/
    end
  end

  context 'region is invalid' do
    it 'raises an error' do
      ENV['AWS_REGION'] = 'eu-west-1'
      expect {
        @base_jenkins_ami.discover_base_ami
      }.to raise_error 'eu-west-1 is illegitimate or unsupported region'
    end
  end

  context 'region is not set' do
    it 'raises an error' do
      ENV['AWS_REGION'] = nil
      expect {
        @base_jenkins_ami.discover_base_ami
      }.to raise_error 'AWS_REGION must be set in environment'
    end
  end
end
