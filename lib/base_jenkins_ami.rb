class BaseJenkinsAmi
  REGION_BASE_AMIS = {
    'us-east-1' => 'ami-e2754888',
    'us-west-2' => 'ami-677c9e07'
  }

  def discover_base_ami
    if ENV['AWS_REGION'].nil?
      raise 'AWS_REGION must be set in environment'
    else
      base_ami = REGION_BASE_AMIS[ENV['AWS_REGION']]

      if base_ami.nil?
        raise "#{ENV['AWS_REGION']} is illegitimate or unsupported region"
      else
        base_ami
      end
    end
  end
end