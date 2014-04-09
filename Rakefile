require 'find'
require 'fileutils'
require 'colorize'
require 'thread'

desc "Some task"
task :clog, [:workspace] do |t, args|
  args.with_defaults(:workspace => "#{ENV['WORKSPACE']}", :repeat => 1)

  controller_dir = args[:workspace]

  report_path = "#{controller_dir}/index.html"
  
  print "start--".yellow

  # creating a new mutex for threading
  mutex = Mutex.new

  # creaing an html file
  begin
    file = File.open(report_path, "w")
    file.write("<html><head></head><body><table>") 
  rescue IOError => e
    #some error occur, dir not writable etc.
  ensure
    file.close unless file == nil
  end

  # getting list of committers
  committers = `git log --raw | grep "^Author:" | sort | uniq | sed -e 's/^Author: //g' -e 's/<.*//g'`.split("\n")

  # calculating their contrinbution percentage on each file
  ex1 = "#{controller_dir}/Pods/**/*"
  ex2 = "#{controller_dir}/Dependencies/**/*"
  ex3 = "#{controller_dir}/UnitTests/**/*"
  ex4 = "*.framework$"
  
  FileList["#{controller_dir}/**/*.m", "#{controller_dir}/**/*.h"].exclude(ex1, ex2, ex3, ex4).each do |path|
    # puts path
    
    
    Thread.new do 
      mutex.synchronize do
        print ".".green
        
        total_file_lines = `wc -l \"#{path}\" | awk '{print $1}'`.chomp.to_f
        
        committers.each do |commiter|
          user_commits = `git blame \"#{path}\" | grep -cow \"#{commiter}\"`.chomp.to_f
          contribution_percentage = (user_commits / total_file_lines * 100).round(2)
          # print "#{user_commits} / #{total_file_lines}    "
          # puts "#{commiter}: #{contribution_percentage}% #{path}" if contribution_percentage != 0
          
          # modifying the html file
          if contribution_percentage != 0
            begin
                file = File.open(report_path, "a")
                file.write("<tr><td>#{commiter}</td><td>#{contribution_percentage}%</td><td>#{path}</td></tr>") 
            rescue IOError => e
              #some error occur, dir not writable etc.
            ensure
              file.close unless file == nil
            end
          end
        end
      end
    end
  end

  # waiting for the threads to finish
  mutex.lock

  puts "hello there"

  # closing the html file
  begin
    file = File.open(report_path, "a")
    file.write("</table></body></html>") 
  rescue IOError => e
    #some error occur, dir not writable etc.
  ensure
    file.close unless file == nil
  end

  puts "--end".yellow
end
