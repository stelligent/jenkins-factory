CloudFormation {

  IAM_Role('JenkinsInstanceRole') {
    AssumeRolePolicyDocument JSON.load <<-END
      {
        "Statement":[
          {
            "Sid":"1",
            "Effect":"Allow",
            "Principal":{
              "Service":[
                "ec2.amazonaws.com"
              ]
            },
            "Action":"sts:AssumeRole"
          }
        ]
      }
    END

    Path '/'

    Policies JSON.load <<-END
      [
        {
          "PolicyName":"JenkinsGodlikeWreckYourAccountPolicy",
          "PolicyDocument":{
            "Version":"2012-10-17",
            "Statement": [
              {
                "Action": [
                  "*"
                ],
                "Effect": "Allow",
                "Resource": "*"
              }
            ]
          }
        }
      ]
    END
  }

  IAM_InstanceProfile('JenkinsInstanceProfile') {
    Path '/'
    Roles [ Ref('JenkinsInstanceRole') ]
  }

  EC2_SecurityGroup('JenkinsSecurityGroup') {
    VpcId vpc_id
    GroupDescription 'Will mostly be phoning home to CP'
  }

  %w(22 8080).each do |ingress_port|
    EC2_SecurityGroupIngress("SecurityGroupIngress#{ingress_port}") {
      GroupId Ref('JenkinsSecurityGroup')
      IpProtocol 'tcp'
      FromPort ingress_port.to_s
      ToPort ingress_port.to_s
      CidrIp jenkins_ingress_ssh_cidr
    }
  end

  EC2_Instance('JenkinsInstance') {
    ImageId jenkins_base_ami_id
    InstanceType 'm4.large'
    KeyName jenkins_ec2_key_pair_name

    IamInstanceProfile Ref('JenkinsInstanceProfile')

    NetworkInterfaces [
      NetworkInterface {
        GroupSet Ref('JenkinsSecurityGroup')
        AssociatePublicIpAddress associate_public_ip_address
        DeviceIndex 0
        DeleteOnTermination true
        SubnetId subnet_id
      }
    ]

    start_jenkins_commands = [
      "#!/bin/bash -xe\n",
      "yum update -y aws-cfn-bootstrap\n",
      "yum -y upgrade\n",
      "service jenkins start\n"
    ]

    cfn_signal_commands = [
      '/opt/aws/bin/cfn-signal -e $? ',
      '                        --stack ', Ref('AWS::StackName'),
      '                        --resource JenkinsInstance ',
      '                        --region ',Ref('AWS::Region'),"\n"
    ]

    userdata_commands = start_jenkins_commands + extra_userdata + cfn_signal_commands
    UserData FnBase64(FnJoin(
                        '',
                        userdata_commands
                      ))

    CreationPolicy('ResourceSignal', { 'Count' => 1,  'Timeout' => 'PT15M' })
  }

  Output(:JenkinsURL,
         FnJoin('', [ 'http://', FnGetAtt('JenkinsInstance', 'PublicIp'), ':8080/']))
}
