module MailRemindersHelper
  def options_from_queries(project = nil)
    issues = IssueQuery.visible.order("#{Query.table_name}.name ASC")

    if project
      issues = issues.where(['project_id IS NULL OR project_id = ?', project.id])
    else
      issues = issues.where('project_id IS NULL')
    end

    issues.map { |q| [q.name, q.id] }
  end

  def query_headline(query)
    query.project ? "#{query.project}: #{query.name}" : query.name
  end

  def reminders_intervals_for_options
    MailReminder.intervals.collect {|i| [l(i).capitalize, i.to_s]}
  end

  def content_for_column(column, issue)
    value = column.value(issue)

    case value.class.name
    when 'String'
      if column.name == :subject
        link_to issue.subject, issue_url(issue)
      else
        h(value)
      end
    when 'Time'
      format_time(value)
    when 'Date'
      format_date(value)
    when 'Fixnum', 'Float'
      if column.name == :done_ratio
        progress_bar(value, :width => '80px')
      else
        h(value.to_s)
      end
    when 'User'
      link_to "#{value.firstname} #{value.lastname}", user_url(value)
    when 'Project'
      link_to value.name, project_url(value)
    when 'Version'
      # Turn off link to version temporarly since
      # routes are not correct in the Redmine
      # version 1.2.1
      #link_to(h(value), version_url(value))
      h(value.name)
    when 'TrueClass'
      l(:general_text_Yes)
    when 'FalseClass'
      l(:general_text_No)
    when 'Issue'
      link_to value.subject, issue_url(value)
    else
      h(value)
    end
  end
end
