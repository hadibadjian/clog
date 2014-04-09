require 'find'
require 'fileutils'
require 'colorize'
require 'work_queue'

desc "clog task"
task :clog, [:workspace] do |t, args|
  args.with_defaults(:workspace => "#{ENV['WORKSPACE']}", :repeat => 1)

  controller_dir = args[:workspace]

  report_path = "#{controller_dir}/index.html"

  # creating a new mutex for threading
  workers = WorkQueue.new 5

  # creaing an html file
  write_html_begining(report_path)

  # getting list of committers
  puts "getting list of committers ..."
  committers = `git log --raw | grep "^Author:" | sort | uniq | sed -e 's/^Author: //g' -e 's/<.*//g'`.split("\n")
  committers.uniq!

  # calculating their contribution percentage on each file
  ex1 = "#{controller_dir}/Pods/**/*"
  ex2 = "#{controller_dir}/Dependencies/**/*"
  ex3 = "#{controller_dir}/UnitTests/**/*"
  ex4 = ".*framework.*"
  
  puts "processing files ..."
  start_time = Time.now
  puts "start [#{start_time}]--".yellow
  FileList["#{controller_dir}/**/*.m", "#{controller_dir}/**/*.h"].exclude(ex1, ex2, ex3, ex4).each do |path|
    print ".".green
    
    write_table_section_header(report_path, path)

    total_file_lines = `wc -l \"#{path}\" | awk '{print $1}'`.chomp.to_f
    
    committers.each do |committer|
      workers.enqueue_b do
        committer.strip!
        user_commits = `git blame \"#{path}\" | grep -cow \"#{committer}\"`.chomp.to_f
        contribution_percentage = (user_commits / total_file_lines * 100).round(2)
        
        # modifying the html file
        if contribution_percentage > 10
          write_table_section_row(report_path, user_commits, total_file_lines, contribution_percentage, committer)
        end
      end
    end

    workers.join

    write_table_section_footer(report_path, path)
  end

  # closing the html file
  write_html_ending(report_path)
  puts ""
  end_time = Time.now
  puts "--end[#{end_time}]".yellow

  elapsed_time = end_time - start_time
  puts "processed in #{elapsed_time} seconds".red
end

def write_html_begining(report_path)
  begin
    file = File.open(report_path, "w")
    file.write(
      "<html>
        <head>
          <title>Contribution Log</title>
          <script src=\"http://code.jquery.com/jquery-1.11.0.min.js\"></script>
          <script src=\"http://benpickles.github.io/peity/jquery.peity.min.js\"></script>
          <script src=\"http://netdna.bootstrapcdn.com/bootstrap/3.1.1/js/bootstrap.min.js\"></script>
          <link rel=\"stylesheet\" href=\"http://netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap.min.css\">
          <script>
            window.onload = function()
            {
              $(\"span.pie\").peity(\"pie\")
            }
          </script>
          <style>
            body
            {
              padding: 20px;
            }
            .full_path
            {
              font-size: 10px;
            }
            .base_name
            {
              font-size: 1em;
            }
            .percentage
            {
              font-size: 12px;
            }
            .committer
            {
              font-size: 14px;
            }
            .h1
            {
              font-size: 2em;
            }
            .footer
            {
              font-size: 1.5em;
            }
          </style>
        </head>
        <body>
          <div class=\"h1\">
            <p>Contribution Log created at #{Time.now}</p>
          </div>
          <table>"
      ) 
  ensure
    file.close unless file == nil
  end
end

def write_table_section_header(report_path, file_path)
  begin
    file = File.open(report_path, "a")
    file_name = File.basename(file_path)
    file.write("<tr><td class=\"base_name\">#{file_name}</td>")
  ensure
    file.close unless file == nil
  end
end

def write_table_section_footer(report_path, file_path)
  begin
    file = File.open(report_path, "a")
    file.write("</tr><tr><td class=\"full_path\">#{file_path}<td></tr>")
  ensure
    file.close unless file == nil
  end
end

def write_table_section_row(report_path, user_commits, total_lines, percentage, committer)
  class_label = ""
  case percentage
  when 80..100
    class_label = "label-primary"
  when 50..79
    class_label = "label-info"
  when 0..50
    class_label = "label-default"
  end

  begin
    file = File.open(report_path, "a")
    file.write(
      "
        <td>
          <span class=\"pie\">#{user_commits}/#{total_lines}</span>
          <span class=\"percentage\">&nbsp#{percentage}%&nbsp</span><br />
          <span class=\"committer\">#{committer}</span>
        </td>
      "
      )
  ensure
    file.close unless file == nil
  end
end

def write_html_ending(report_path)
  begin
    file = File.open(report_path, "a")
    file.write(
      "     </table>
            <div class=\"footer pull-right\">
              <p>visit <a href=\"https://github.com/hadibadjian/clog\">clog Github</a></p>
            </div>
          </body>
        </html>")
  ensure
    file.close unless file == nil
  end
end
