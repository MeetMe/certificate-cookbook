#
# Cookbook Name:: certificate
# Recipe:: default
#
# Copyright 2013, MeetMe, Inc.
#
directory node[:certificate][:directory] do
  action :create
  owner  'root'
  group  'wheel'
end