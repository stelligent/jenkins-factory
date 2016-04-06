require 'jenkins_api_client'

# i guess also consider using local jenkins cli from user data?
class JobSeeder
  def seed_jobs(jenkins_connection_info:,
                jobs_location:)

    client = jenkins_api_client jenkins_connection_info: jenkins_connection_info

    job_name = 'job-seed'
    if client.job.exists? job_name
      client.job.delete job_name
    end

    seed_xml = patch_job_seed jobs_location: jobs_location

    client.job.create job_name,
                      seed_xml

    client.job.build job_name
  end

  # only exposed for testing, don't call me
  # ok yea ERB more elegant but i'm feeling lazy
  def patch_job_seed(jobs_location:)
    seed_xml = IO.read path_to_seed
    seed_xml.gsub!(/<%= @job_definition_relative_path %>/, jobs_location['job_definition_relative_path'])
    seed_xml.gsub!(/<%= @job_repo_branch %>/, jobs_location['job_repo_branch'])
    seed_xml.gsub!(/<%= @job_repo %>/, jobs_location['job_repo'])
    seed_xml
  end

  private

  def path_to_seed
    File.join(File.dirname(File.expand_path(__FILE__)), 'xml', 'job-seed-config.xml.erb')
  end

  def jenkins_api_client(jenkins_connection_info:)
    JenkinsApi::Client.new server_url: jenkins_connection_info['jenkins_url'],
                           username: jenkins_connection_info['jenkins_user'],
                           password: jenkins_connection_info['jenkins_pass']
  end
end