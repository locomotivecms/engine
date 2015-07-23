# Note: http://stackoverflow.com/questions/13950005/rails-formatting-a-date-hhmm-for-today-yesterday-for-yesterday-weekday
Time::DATE_FORMATS[:humanized_ago]  = ->(time) do
  start_time  = Time.now.beginning_of_day
  end_time    = Time.now.end_of_day

  if time.between?(start_time, end_time)
    I18n.t('date.today_at') + ' ' + I18n.l(time, format: :time)
  elsif time.between?(start_time - 1.day, end_time - 1.day)
    I18n.t('date.yesterday_at') + ' ' + I18n.l(time, format: :time)
  elsif time.between?(start_time - 6.day, end_time - 2.day)
    I18n.l(time, format: :short)
  else
    I18n.l(time, format: :default)
  end
end
