require 'find'
require 'fileutils'

require 'colorize'
require 'work_queue'

require 'html_composer'

class GitStrider
  def initialize(workspace, queue_size)
    @root = workspace
    @queue_size = queue_size
  end
  
  def generate
    puts @root
    @report_path = "#{@root}/git_strider/report.html"

    # calculating their contribution percentage on each file
    ex1 = "#{@root}/Pods/**/*"
    ex2 = "#{@root}/Dependencies/**/*"
    ex3 = "#{@root}/UnitTests/**/*"
    ex4 = ".*framework.*"
    
    puts "processing files ..."
    start_time = Time.now
    puts "start [#{start_time}]--".yellow

    # getting list of committers
    puts "getting list of committers ..."
    committers = `git log --raw | grep "^Author:" | sort | uniq | sed -e 's/^Author: //g' -e 's/<.*//g'`.split("\n")
    committers.uniq!

    # creaing an html file
    html_composer = HtmlComposer.new(@report_path)
    html_composer.write_html_header

    # creating a new mutex for threading
    workers = WorkQueue.new @queue_size

    FileList["#{@root}/**/*.m", "#{@root}/**/*.h"].exclude(ex1, ex2, ex3, ex4).each do |path|
      workers.enqueue_b do
        puts "  => Processing #{File.basename(path)}".white
        html_composer.write_table_section_header

        total_file_lines = File.foreach(path).count.to_f
        
        users_data = Hash.new

        committers.each do |committer|
          committer.strip!
          user_commits = `git blame \"#{path}\" | grep -cow \"#{committer}\"`.chomp.to_f
          
          users_data[committer] = { :commits => user_commits,
                                    :file_lines => total_file_lines }
        end

        html_composer.write_table_section_row(path, users_data)
        html_composer.write_table_section_footer(path)
        html_composer.flush_table_section
      end
    end

    workers.join

    # closing the html file
    html_composer.write_html_footer

    puts ""
    end_time = Time.now
    puts "--end[#{end_time}]".yellow

    elapsed_time = end_time - start_time
    puts "Processed in #{elapsed_time} secs".white
  end
end
