require 'find'
require 'fileutils'
require 'parallel'

require 'gitstrider/html_composer'

class GitStrider

  def initialize(workspace, processes_threads, report_path = "CodeQualityReports/GitStrider/git_contribution.html")
    @root = workspace
    in_threads   = 20
    in_processes = processes_threads[:max_threads]

    @config = Hash.new
    if in_processes and in_threads
        puts "Running in #{in_processes} threads"
        @config = {:in_processes => in_processes, :in_threads => in_threads}
    else
        puts "Running in 20 threads"
        @config = {:in_processes => 20, :in_threads => 20}
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

    FileUtils.mkdir_p "#{@root}/gs_temp"
    Parallel.each(files, :in_processes => @config[:in_processes]) do |path|
      process_file(html_composer, path)
    end
    FileUtils.rm_r "#{@root}/gs_temp"

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
        temp_file = "#{@root}/gs_temp/gs_temp_#{File.basename(path)}"

        # taking committers data and storing them temporarily
        `git blame --line-porcelain \"#{path}\" | sed -n 's/^author //p' | sort | uniq -c | sort -rn > #{temp_file}`

        users_data = Hash.new
        total_file_lines = File.foreach(path).count.to_f
        
        Parallel.each(@committers, :in_threads => @config[:in_threads]) do |committer|
          committer.strip!
          user_commits = `cat #{temp_file} | grep \"#{committer}\" | sed -n 's/[a-zA-Z].*//p'`.chomp.to_f
          
          users_data[committer] = { :commits => user_commits,
                                    :file_lines => total_file_lines }
        end
        
        html_composer.write_user_data(path, users_data)
    end
end
