module Util
  def self.secrets_file_path(yml_path)
    yml_split_path = File.split(yml_path)
    secret_name_base = File.basename yml_split_path[1], '.yml'
    File.join yml_split_path[0], "#{secret_name_base}_secret.yml"
  end

  def self.merge_secrets(yml_path)
    jenkins_settings = YAML.load_file(yml_path)
    secret_properties = secrets_file_path(yml_path)
    jenkins_settings.merge! secret_properties
    jenkins_settings
  end

  def self.transform_keys_to_symbols(hash)
    hash.keys.each do |k|
      hash[k.to_sym] = hash[k]
      hash.delete k
    end
  end

  def self.discover_my_public_ip_cidr
    my_ip = `dig @resolver1.opendns.com myip.opendns.com +short`
    "#{my_ip.chomp}/32"
  end
end