class Check < ActiveRecord::Base
  belongs_to :word

  DAY_START_HOUR = 3  # TODO: 就寝時間に合わせた時間なら設定化する

  scope :today, -> { where('created_at > ?', Time.now.beginning_of_day + DAY_START_HOUR.hours) }

  after_touch :sync_created_on

  def sync_created_on
    self.created_on = self.created_at.to_date
  end

  class << self
    def checks_count_per_date
      Check.group(:created_on).order(:created_on).count(:created_on).to_a
    end
  end
end
