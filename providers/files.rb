def whyrun_supported?
  true
end


def load_current_resource
  @current_resource = Chef::Resource::CertificateFiles.new(@new_resource.name)

  cert_file, key_file, cacert_file = create_paths(@new_resource.hostname,
                                                  @new_resource.path)

  if ::File.exists?(cert_file)
    @current_resource.certificate = ::File.read(cert_file)
  end

  if ::File.exists?(key_file)
    @current_resource.key = ::File.read(key_file)
  end

  if ::File.exists?(cacert_file)
    @current_resource.cacert = ::File.read(cacert_file)
  end
end



action :create do
  # Initialize, finding the right data bag item or raising an exception
  cert, cert_file, key_file, cacert_file = find_certificate

  # Create the certificate file unless it exists and the values are the same
  unless @current_resource.certificate.eql?(cert['certificate'])
    converge_by("create certificate file #{cert_file}") do
      create_file(cert_file, cert['certificate'])
    end
  end

  # Create the key file unless it exists and the values are the same
  unless @current_resource.key.eql?(cert['key'])
    converge_by("create key file #{key_file}") do
      create_file(key_file, cert['key'])
    end
  end

  # Create the cacert file if it is set unless it exists and the values are the same
  unless cert['cacert'].nil? || @current_resource.cacert.eql?(cert['cacert'])
    converge_by("create cacert file #{cacert_file}") do
      create_file(cacert_file, cert['cacert'])
    end
  end
end


action :delete do
  # Initialize, finding the right data bag item or raising an exception
  cert, cert_file, key_file, cacert_file = find_certificate

  if ::File.exists?(cert_file)
    converge_by("delete certificate file #{cert_file}") do
      remove_file(cert_file)
    end
  end

  if ::File.exists?(key_file)
    converge_by("delete key file #{key_file}") do
      remove_file(key_file)
    end
  end

  if ::File.exists?(cacert_file)
    converge_by("delete ca certificate file #{cacert_file}") do
      remove_file(cacert_file)
    end
  end
end



private


def base_hostname(hostname)
  hostname[/^(\*\.|)([\w\-_\.]+)$/, 2]
end


def create_file(path, content)
  Chef::Log.debug("Creating file at #{path}")
  ::File.open(path, "w") do |f|
    f.write(content)
  end
  Chef::Log.info("#{@new_resource} created file #{path}")
  @new_resource.updated_by_last_action(true)
end


def create_paths(hostname, path)
  base_file = base_hostname(hostname)
  ["#{path}/#{base_file}.cert.pem",
   "#{path}/#{base_file}.key.pem",
   "#{path}/#{base_file}.cacert.pem"]
end


def find_certificate
  values = [search_data_bag(@new_resource.hostname)]
  values.concat(create_paths(@new_resource.hostname, @new_resource.path))
  values
end


def remove_file(path)
  if ::File.exists?(path)
    ::File.unlink(path)
    Chef::Log.info("#{@new_resource} deleted file #{path}")
    new_resource.updated_by_last_action(true)
  end
end


def search_data_bag(hostname)
  certificates = data_bag(:certificates)
  [hostname, wildcard(hostname)].each do |value|
    Chef::Log.debug("Looking for #{value} in data bag items")
    certificates.each do |item_id|
      Chef::Log.debug("Checking certificate #{item_id} for #{value}")
      cert = data_bag_item(:certificates, item_id)
      if cert['valid_hostnames'].include?(value)
        Chef::Log.debug("#{@new_resource} found certificate for #{value} in #{item_id}")
        return cert
      end
    end
  end
  raise "No certificate was found for #{hostname}"
end


def wildcard(hostname)
  hostname.sub(/^(?<short>[\w\-_]+)\.(?<domain>.*)$/, '*.\k<domain>')
end