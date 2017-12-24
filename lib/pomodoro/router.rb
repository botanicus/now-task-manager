require 'pathname'

module Pomodoro
  class Router
    def initialize(root_path, date)
      @root_path, @date = Pathname.new(root_path), date
    end

    def features_path
      @root_path.join("#{@date.year}/features")
    end

    # Plan.
    def week_plan_path
      @root_path.join("#{@date.year}/features/weeks/#{@date.cweek}.feature")
    end

    def month_plan_path
      @root_path.join("#{@date.year}/features/months/#{@date.strftime('%B')}.feature")
    end

    def quarter_plan_path
      @root_path.join("#{@date.year}/features/Q#{(@date.month / 4) + 1}.feature")
    end

    def year_plan_path
      @root_path.join("#{@date.year}/features/#{@date.year}.feature")
    end

    # Review.
    def week_review_path
      self.week_plan_path.sub(/\.feature$/, '.review')
    end

    def month_review_path
      self.month_plan_path.sub(/\.feature$/, '.review')
    end

    def quarter_review_path
      self.quarter_plan_path.sub(/\.feature$/, '.review')
    end

    def year_review_path
      self.year_plan_path.sub(/\.feature$/, '.review')
    end
  end
end
