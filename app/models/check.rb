class Check < ActiveRecord::Base
  belongs_to :word
  attr_accessible :newstat, :oldstat, :word_id # TODO: Strong Parametersを使う

  scope :today, -> { where('created_at > ?', Time.now.beginning_of_day + 3.hours) } # TODO: 3.hoursは就寝時間に合わせた時間なら設定化する

  class << self
    def check_months # TODO: メソッド名の意図
      checks = Check.order(:created_at)
      checks.group_by { |t| t.created_at.to_date }
    end
  end
end
