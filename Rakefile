desc "Some task"

task :clog, [:workspace] do |t, args|
  args.with_defaults(:workspace => "./*", :repeat => 1)
  puts args[:workspace]

  controller_dir = args[:workspace]
  files = FileList.new("#{controller_dir}") do |file|
    
    # puts "#{user_commits}/#{total_file_lines}"
  end

  files.each { |file| 
    puts "#{file}"
    total_file_lines = `wc -l #{file} | awk '{print $1}'`
    user_commits = `git blame #{file} | grep -cow \"Hadi\"`

    if total_file_lines.to_i != 0 && user_commits.to_i != 0
      puts "#{file}"
      contribution_percentage = user_commits.to_i / total_file_lines.to_i * 100
      puts "#{contribution_percentage}%"
    end
  }
  
end