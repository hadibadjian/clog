# GitStrider
[![Gem Version](https://badge.fury.io/rb/gitstrider.svg)](http://badge.fury.io/rb/gitstrider)

GitStrider provides a contribution report for a git enabled project. This report can be used as a guide to determine a file's owner for code maintenance or reviews.

## Getting Started

1 - Add GitStrider to your `Gemfile` and `bundle install`:

```ruby
gem 'gitstrider'
```

2 - Create a rake task

```ruby
require 'gitstrider'

task :gitstrider do
  # Set the project workspace. If using CI, get the WORKSPACE environment parameter
  workspace = ENV['WORKSPACE']
  
  strider = GitStrider.new workspace, {max_threads: 10}
  
  # Optional - change the report output, default is the one specified below
  # strider.report_path "CodeQualityReports/GitStrider/git_contributions.html"
  
  in1 = "#{workspace}/**/*.h"
  in2 = "#{workspace}/**/*.m"
  strider.include_files [in1, in2]
  
  ex1 = "#{workspace}/Pods/**/*"
  ex2 = "#{workspace}/Dependencies/**/*"
  ex3 = "#{workspace}/UnitTests/**/*"
  ex4 = ".*framework.*"
  strider.exclude_files [ex1, ex2, ex3, ex4]
  
  strider.generate
end
```

3 - Generate the report by running the task

```bash
$ rake gitstrider
```

## Sample Output

![sample-report][sample-report]

## License
*[The MIT License (MIT)]*

[The MIT License (MIT)]:https://github.com/hadibadjian/gitstrider/blob/master/LICENSE
[sample-report]:https://github.com/hadibadjian/gitstrider/blob/master/sample/screen_shot.png?raw=true
