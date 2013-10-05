class Check < ActiveRecord::Base
  belongs_to :word
  attr_accessible :newstat, :oldstat, :word_id # TODO: Strong Parametersを使う

  DAY_START_HOUR = 3  # TODO: 就寝時間に合わせた時間なら設定化する

  scope :today, -> { where('created_at > ?', Time.now.beginning_of_day + DAY_START_HOUR.hours) }

  class << self
    def checks_per_date
      checks = Check.order(:created_at)
      checks.group_by { |t| t.created_at.to_date }
    end
  end
end
