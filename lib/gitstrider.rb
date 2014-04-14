require 'find'
require 'fileutils'
require 'parallel'

require 'html_composer'

class GitStrider

  def initialize(workspace, processes_threads, report_path = "CodeQualityReports/GitStrider/git_contribution.html")
    @root = workspace
    in_threads   = processes_threads[:max_threads]
    in_processes = 1 # processes_threads[:processes]

    @config = Hash.new
    if in_processes and in_threads
        puts "Running in #{in_processes}:#{in_threads} processes"
        @config = {:in_processes => in_processes, :in_threads => in_threads}
    else
        puts "Running in _1:8_ threads"
        @config = {:in_processes => 1, :in_threads => 8}
    end

    @report_path = report_path
  end

  # Changing the default report path
  def report_path(report_path)
      @report_path = report_path
  end

  def include_files(included_files)
      @included_files = included_files
  end

  # Excluding files
  def exclude_files(excluded_files)
      @excluded_files = excluded_files
  end
  
  # Generating the contribution path
  def generate
    puts @root
    
    puts "Processing files ..."
    start_time = Time.now
    puts "start --"

    # getting list of committers
    puts "Getting list of committers ..."
    @committers = `git log --raw | grep "^Author:" | sort | uniq | sed -e 's/^Author: //g' -e 's/<.*//g'`.split("\n")
    @committers.uniq!

    # creaing an html file
    html_composer = HtmlComposer.new(@root, @report_path)
    html_composer.write_html_header

    files = FileList.new() do |f|
      @excluded_files.each { |e| 
        f.exclude(e)
        puts "Excluded #{e}" 
      }
    end
    @included_files.each do |i|
      files.add(i)
    end

    Parallel.each(files, :in_processes => @config[:in_processes]) do |path|
      process_file(html_composer, path)
    end

    # closing the html file
    html_composer.write_html_footer

    puts ""
    puts "-- end"

    elapsed_time = (Time.now - start_time).round(2)
    puts "Processed in #{elapsed_time} secs"
  end

  private
    def process_file(html_composer, path)
        puts "  => Processing #{File.basename(path)}"

        users_data = Hash.new
        total_file_lines = File.foreach(path).count.to_f
            
        Parallel.each(@committers, :in_threads => @config[:in_threads]) do |committer|
          committer.strip!
          user_commits = `git blame \"#{path}\" | grep -cow \"#{committer}\"`.chomp.to_f
          
          users_data[committer] = { :commits => user_commits,
                                    :file_lines => total_file_lines }
        end
        
        html_composer.write_user_data(path, users_data)
    end
end
