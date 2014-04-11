require 'fileutils'

class HtmlComposer
  def initialize(html_path)
    @html_path = html_path
  end
  
  def write_html_header
    begin
      File.delete(@html_path) if File.exists?(@html_path)

      file = File.open(@html_path, "w")
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
                display: inline-block;
                text-align: center;
              }
              .committer
              {
                font-size: 14px;
                display: inline-block;
                text-align: center;
              }
              .h1
              {
                font-size: 2em;
              }
              .footer
              {
                font-size: 1.5em;
              }
              .user_data
              {
                float: left;
                width: 80px;
                margin-left: 5px;
              }
            </style>
          </head>
          <body>
            <div class=\"h1\">
              <p>Contribution Log created at #{Time.now}</p>
            </div>
            <table>") 
    ensure
      file.close unless file == nil
    end
  end

  def write_html_footer
    begin
      file = File.open(@html_path, "a")
      file.write(
        "   </table>
            <div class=\"footer pull-right\">
              <p>visit <a href=\"https://github.com/hadibadjian/git_strider\">git-strider Github</a></p>
            </div>
          </body>
        </html>")
    ensure
      file.close unless file == nil
    end
  end

  def write_table_section_header
    @new_entry = String.new

    @new_entry.concat("<tr />")
  end

  def write_table_section_footer(file_path)
    @new_entry.concat("<tr>
                        <td colspan=\"2\" class=\"full_path\">#{file_path}<td>
                      </tr>")
  end

  def write_table_section_row(file_path, users_data)
    file_name = File.basename(file_path)

    @new_entry.concat("<tr>
                        <td class=\"base_name\">
                          #{file_name}
                        </td>
                        <td>");

    users_data.each { |key, user_data|
      user_name    = key
      user_commits = user_data[:commits]
      file_lines   = user_data[:file_lines].to_f
      percentage   = (user_commits / file_lines * 100).round(2)

      if percentage > 10
        @new_entry.concat("<div class=\"user_data\">
                            <span class=\"pie\">#{user_commits}/#{file_lines}</span>
                            <span class=\"percentage\">&nbsp#{percentage}%&nbsp</span><br />
                            <span class=\"committer\">#{user_name}</span>
                          </div>")
      end
    }
    @new_entry.concat("</td></tr>")
  end

  def flush_table_section
    begin
      file = File.open(@html_path, "a")
      file.write(@new_entry)
    ensure
      file.close unless file == nil
    end
  end
end