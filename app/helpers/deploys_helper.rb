require 'coderay'

module DeploysHelper
  def deploy_active?
    @deploy.active? && (JobExecution.find_by_id(@deploy.job_id) || JobExecution.enabled)
  end

  def deploy_page_title
    "#{@deploy.stage.name} deploy (#{@deploy.status}) - #{@project.name}"
  end

  def file_status_label(status)
    mapping = {
      "added"    => "success",
      "modified" => "info",
      "removed"  => "danger"
    }

    type = mapping[status]

    content_tag :span, status[0].upcase, class: "label label-#{type}"
  end

  def file_changes_label(count, type)
    content_tag :span, count.to_s, class: "label label-#{type}" unless count.zero?
  end

  def github_users(users)
    users.map {|user| github_user_avatar(user) }.join(" ").html_safe
  end

  def github_user_avatar(user)
    link_to user.url, title: user.login do
      image_tag user.avatar_url, width: 20, height: 20
    end
  end

  def deploy_status_panel(deploy)
    mapping = {
      "succeeded" => "success",
      "failed"    => "danger",
      "errored"   => "warning"
    }

    status = mapping.fetch(deploy.status, "info")

    if deploy.finished?
      content = "#{deploy.summary} #{time_ago_in_words(deploy.created_at)} ago"
      content += ", it took #{duration_text(deploy)}"
    else
      content = deploy.summary
    end

    content_tag :div, content, class: "alert alert-#{status}"
  end

  def duration_text(deploy)
    seconds  = (deploy.updated_at - deploy.created_at).to_i
    duration = ""

    if seconds > 60
      minutes = seconds / 60
      seconds = seconds - minutes * 60

      duration += "#{minutes} minute".pluralize(minutes)
    end

    duration += (seconds > 0 || duration.size == 0 ? " #{seconds} second".pluralize(seconds) : "")
  end

  def syntax_highlight(code, language = :ruby)
    CodeRay.scan(code, language).html.html_safe
  end

  def stages_select_options
    @project.stages.unlocked.map do |stage|
      [stage.name, stage.id, 'data-confirmation' => stage.confirm?]
    end
  end
end
