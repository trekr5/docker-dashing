require 'open3'
require 'fileutils'

#defaults
if(ENV['HOSTNAME'].nil?)
	HOSTNAME = ENV['HOSTNAME']
else
  HOSTNAME = 'artifactory.justgiving.com'
end

if(!ENV['GO_PIPELINE_LABEL'].nil?)
	VERSION = ENV['GO_PIPELINE_LABEL']
else
  VERSION = "0.0.1"
end

if(!ENV['USERNAME'].nil?)
	USERNAME = ENV['USERNAME']
else
  USERNAME = "notset"
end

if(!ENV['USERNAME'].nil?)
	PASSWORD = ENV['PASSWORD']
else
  PASSWORD = "notset"
end

TAG = "#{HOSTNAME}/base/dashing:#{VERSION}"
FROM_VERSION = "notset"
ENV.each do |n,v|
  if(n.include?('GO_DEPENDENCY_LABEL_'))
    FROM_VERSION = v
  end
end
if(FROM_VERSION != 'notset')
  puts("Setting the docker file FROM to use dependency :#{FROM_VERSION}")
end

module Utils
  class Subprocess
    def initialize(cmd, &block)
      # see: http://stackoverflow.com/a/1162850/83386
      Open3.popen3(cmd) do |stdin, stdout, stderr, thread|
        # read each stream from a new thread
        { :out => stdout, :err => stderr }.each do |key, stream|
          Thread.new do
            until (line = stream.gets).nil? do
              # yield the block depending on the stream
              if key == :out
                yield line, nil, thread if block_given?
              else
                yield nil, line, thread if block_given?
              end
            end
          end
        end

        thread.join # don't exit until the external process is done
        exit_code = thread.value
		if(exit_code != 0)
			puts("Failed to execute_cmd #{cmd} exit code: #{exit_code}")
			Kernel.exit(false)
		end
      end
    end
  end
end

def execute_cmd(cmd,chdir=File.dirname(__FILE__))
	puts("execute_cmd: #{cmd}")	
	Utils::Subprocess.new cmd do |stdout, stderr, thread|
  		puts "\t#{stdout}"
  		if(stderr.nil? == false)
  			puts "\t#{stderr}"	
  		end
	end
	#puts("finished")
end

task :default => [:patch_from,:inject_labels,:clean,:build,:docker_image,:docker_push] do 
end

task :clean do 
  system("docker rm -v $(docker ps -aq -f status=exited)")
  system("docker rmi -f $(docker images -q -a -f dangling=true)")
end

task :build do 
  
end 

task :patch_from do 
  if(FROM_VERSION != 'notset')
    lines = []
    File.readlines('Dockerfile').each do |line|
      if(line.include?('FROM'))
         bits = line.split(':')
         lines << "#{bits[0]}:#{FROM_VERSION}"
       else
         lines << line
       end
    end
    File.open("Dockerfile", "w+") do |f|
      f.puts(lines)
    end
  end
end

task :inject_labels do 
    lines = []
    File.readlines('Dockerfile').each do |line|
      if(line.include?('FROM'))
         lines << line
          lines << "LABEL build-by=\"automation\" \\
                         build-git=\"#{`git rev-parse --verify HEAD`.chomp}\" \\
                         build-pipeline_name=\"#{ENV['GO_PIPELINE_NAME']}\" \\
                         build-pipeline_label=\"#{ENV['GO_PIPELINE_LABEL']}\" \\   
                         build-date=\"#{Time.now.getutc}\" \\
                         name=\"#{ENV['GO_PIPELINE_NAME']}\" \\
                         vendor=\"Justgiving\" \\
                         license=\"restricted\"                       
                  "
      else
        lines << line
      end
    end
    
    File.open("Dockerfile", "w+") do |f|
      f.puts(lines)
    end
end



task :docker_image do 	
  execute_cmd("docker build --no-cache -t #{TAG} .")
end 

task :docker_push do
 execute_cmd("docker login -u #{USERNAME} -p #{PASSWORD} #{HOSTNAME}")
 puts(TAG)
 execute_cmd("docker push #{TAG} ")
end
