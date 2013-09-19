actions :create, :delete
default_action :create

attribute :hostname, :kind_of => String, :name_attribute => true
attribute :path, :kind_of => String, :default => node[:certificate][:directory]

attr_accessor :certificate
attr_accessor :key
attr_accessor :cacert
