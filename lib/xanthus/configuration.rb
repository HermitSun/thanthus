module Xanthus
  class Configuration
    attr_accessor :name
    attr_accessor :authors
    attr_accessor :affiliation
    attr_accessor :email
    attr_accessor :description
    attr_accessor :share_folder
    attr_accessor :seed
    attr_accessor :params
    attr_accessor :vms
    attr_accessor :scripts
    attr_accessor :jobs
    attr_accessor :github_conf
    attr_accessor :dataverse_conf

    def initialize
      @share_folder = true
      @params = Hash.new
      @vms = Hash.new
      @scripts = Hash.new
      @jobs = Hash.new
    end

    def vm name
      vm = VirtualMachine.new
      yield(vm)
      vm.name = name
      vm.share_folder = @share_folder
      @vms[name] = vm
    end

    def script name
      @scripts[name] = yield
    end

    def job name
      v = Job.new
      yield(v)
      v.name = name
      @jobs[name] = v
    end

    def github
      github = GitHub.new
      yield(github)
      @github_conf = github
    end

    def dataverse
      dataverse = Dataverse.new
      yield(dataverse)
      @dataverse_conf = dataverse
    end

    def to_readme_md
      %Q{
# #{@name}

authors: #{@authors}
affiliation: #{@affiliation}
email: #{@email}

seed: #{@seed}

## Description

#{@description}
      }
    end
  end

  def self.configure
    config = Configuration.new
    yield(config)
    puts "Running experiment #{config.name} with seed #{config.seed}."
    srand config.seed
    config.vms.each do |k, v|
      v.generate_box config
    end

    # initializing storage backends
    config.github_conf.init(config) unless config.github_conf.nil?
    config.dataverse_conf.init(config) unless config.dataverse_conf.nil?

    # executing jobs
    config.jobs.each do |name, job|
      for i in 0..(job.iterations - 1) do
        job.execute config, i
      end
    end

    # finalizing storage backends
    config.github_conf.tag unless config.github_conf.nil?
    config.github_conf.clean unless config.github_conf.nil?
  end
end
