require 'fileutils'

module Pegasus
  class Init
    @@name

    def self.header file
      file.write("# -*- mode: ruby -*-\n")
      file.write("# vi: set ft=ruby\n\n")
    end

    def self.config file
      script = %Q{
# -*- mode: ruby -*-
# vi: set ft=ruby

Pegasus.configure do |config|
  config.name = '#{@@name}'
  config.description = %q{
Describe my super experiment.

It is very cool and interesting!
}
  config.seed = #{Random.new_seed}

  config.script :pre do
    %q{%{
      mkdir wgets
      cd wgets
    }}
  end

  config.script :camflow_start do
    Pegasus::CAMFLOW_START
  end

  config.script :spade_start do
    Pegasus::SPADE_START
  end

  config.script :normal do
    %q{
    2.times.collect do
      'wget http://www.google.com'
    end
    }
  end

  config.script :attack do
    %q{
    2.times.collect do
      'wget http://www.google.com'
    end
    }
  end

  config.script :camflow_stop do
    Pegasus::CAMFLOW_STOP
  end

  config.script :spade_stop do
    Pegasus::SPADE_STOP
  end

  config.script :post do
    %q{%{
      cd ..
      rm -rf wgets
    }}
  end

  config.script :server do
    %q{%{
      mkdir test
    }}
  end

  config.vm :camflow do |vm|
    vm.box = 'michaelh/ubuncam'
    vm.version = '0.0.3'
    vm.ip = '192.168.33.8'
  end

  config.vm :spade do |vm|
    vm.box = 'michaelh/spade'
    vm.memory = 8192
    vm.version = '0.0.3'
    vm.ip = '192.168.33.8'
  end

  config.vm :server do |vm|
    vm.box = 'bento/ubuntu-18.04'
    vm.version = '201812.27.0'
    vm.ip = '192.168.33.3'
  end

  config.job :normal_camflow do |job|
    job.iterations = 2
    job.tasks = {camflow: [:pre, :camflow_start, :normal, :camflow_stop, :post]}
    job.outputs = {camflow: {config: '/etc/camflow.ini', trace: '/tmp/audit.log'}}
  end

  config.job :attack_camflow do |job|
    job.iterations = 2
    job.tasks = {server: [:server], camflow: [:pre, :camflow_start, :attack, :camflow_stop, :post]}
    job.outputs = {camflow: {config: '/etc/camflow.ini', trace: '/tmp/audit.log'}}
  end

  config.job :normal_spade do |job|
    job.iterations = 1
    job.tasks = {spade: [:pre, :spade_start, :normal, :spade_stop, :post]}
    job.outputs = {spade: {trace: '/tmp/audit_cmd.avro'}}
  end

  config.job :attack_spade do |job|
    job.iterations = 2
    job.tasks = {server: [:server], spade: [:pre, :spade_start, :attack, :spade_stop, :post]}
    job.outputs = {spade: {trace: '/tmp/audit_cmd.avro'}}
  end

  config.github do |github|
    github.repo = '<ADD GITHUB REPO user/name>'
    github.token = '<ADD GITHUB TOKEN>'
  end
end
}
      file.write(script)
    end

    def self.init name
      @@name = name
      abort("Error: #{@@name} already exists.") unless !File.exists? name
      FileUtils.mkdir_p @@name
      Dir.chdir @@name do
        puts "Creating experiment #{@@name}..."
        File.open('.pegasus', 'w+') do |f|
          self.header f
          self.config f
        end
      end
      puts 'Experiment created.'
      puts 'Edit #{@@name}/.pegasus to configure your experiment.'
      puts 'To run your experiment "pegasus run".'
    end
  end
end
