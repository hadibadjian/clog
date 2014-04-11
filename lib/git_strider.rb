require 'find'
require 'fileutils'
require 'colorize'
require 'parallel'

require 'html_composer'

class GitStrider

  def initialize(workspace, processes_threads)
    @root = workspace
    in_threads   = processes_threads[:threads]
    in_processes = processes_threads[:processes]

    @config = Hash.new
    if in_processes and in_threads
        puts "Running in #{in_processes}:#{in_threads} processes"
        @config = {:in_processes => in_processes, :in_threads => in_threads}
    else
        puts "Running in _1:8_ threads"
        @config = {:in_processes => 1, :in_threads => 8}
    end
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
    puts "start --".yellow

    # getting list of committers
    puts "getting list of committers ..."
    @committers = `git log --raw | grep "^Author:" | sort | uniq | sed -e 's/^Author: //g' -e 's/<.*//g'`.split("\n")
    @committers.uniq!

    # creaing an html file
    html_composer = HtmlComposer.new(@report_path)
    html_composer.write_html_header

    files = FileList["#{@root}/**/*.m", "#{@root}/**/*.h"].exclude(ex1, ex2, ex3, ex4)
    Parallel.each(files, :in_processes => @config[:in_processes]) do |path|
      process_file(html_composer, path)
    end

    # closing the html file
    html_composer.write_html_footer

    puts ""
    puts "-- end".yellow

    elapsed_time = (Time.now - start_time).round(2)
    puts "Processed in #{elapsed_time} secs".white
  end

  private
    def process_file(html_composer, path)
        puts "  => Processing #{File.basename(path)}".white

        users_data = Hash.new
        total_file_lines = File.foreach(path).count.to_f
            
        Parallel.each(@committers, :in_threads => @config[:in_threads]) do |committer|
          committer.strip!
          user_commits = `git blame \"#{path}\" | grep -cow \"#{committer}\"`.chomp.to_f
          
          users_data[committer] = { :commits => user_commits,
                                    :file_lines => total_file_lines }
        end
        
        html_composer.write_table_section_header
        html_composer.write_table_section_row(path, users_data)
        html_composer.write_table_section_footer(path)
        html_composer.flush_table_section
    end
end
