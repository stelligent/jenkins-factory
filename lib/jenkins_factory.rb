require 'cfndsl_converger'
require_relative 'base_jenkins_ami'
require_relative 'job_seeder'

class JenkinsFactory

  def create(controller_ip:,
             ec2_keypair_name:,
             vpc_id:,
             subnet_id:,

             job_repo:,
             job_repo_branch: 'master',
             job_definition_relative_path:,

             # this is currently baked into the AMI
             jenkins_admin_username:,
             jenkins_admin_password:,

             # crude bash commands, but maybe consider scp a tar of cookbooks?
             extra_user_data_provisioning: [],
             associate_public_ip_address: true)

    customisations = {
      'jenkins_base_ami_id' => BaseJenkinsAmi.new.discover_base_ami,
      'jenkins_ingress_ssh_cidr' => controller_ip,
      'jenkins_ec2_key_pair_name' => ec2_keypair_name,
      'subnet_id' => subnet_id,
      'vpc_id' => vpc_id,
      'associate_public_ip_address' => associate_public_ip_address.to_s,
      'extra_userdata' => extra_user_data_provisioning.to_s
    }

    stack_outputs = converge_jenkins_stack customisations: customisations

    jenkins_connection_info = {
      'jenkins_url' => stack_outputs['JenkinsURL'],
      'jenkins_user' => jenkins_admin_username,
      'jenkins_pass' => jenkins_admin_password
    }

    jobs_location = {
      'job_repo' => job_repo,
      'job_repo_branch' => job_repo_branch,
      'job_definition_relative_path' => job_definition_relative_path
    }

    JobSeeder.new.seed_jobs jenkins_connection_info: jenkins_connection_info,
                            jobs_location: jobs_location

  end

  private

  def converge_jenkins_stack(customisations:)
    converger = CfndslConverger.new
    outputs = converger.converge stack_name: "Jenkins-Factory-#{Time.now.to_i}",
                                 path_to_stack: 'lib/cfndsl/jenkins_cfndsl.rb',
                                 bindings: customisations
    outputs
  end
end