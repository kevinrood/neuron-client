module Neuron
  module Client
    module Model
      module Common
        module AdCalculations
          # This module expects the following methods to be defined:
          # start_datetime (Time, String, or nil)
          # end_datetime (Time, String, or nil)
          # time_zone (String)
          # day_partitions (String, or nil, length = 7*24, matches /^[TF]+$/)
          # daily_cap (FixNum, or nil)
          # overall_cap (FixNum, or nil)
          # ideal_impressions_per_hour (Number, or nil)
          # total_impressed (Integer, >= 0)
          # today_impressed (Integer, >= 0)

          def active?
            calculate_active?(Time.now, total_impressed, today_impressed)
          end

          def pressure
            calculate_pressure(Time.now, total_impressed, today_impressed)
          end

          def calculate_active?(time, total, today)
            time = time.in_time_zone(time_zone)
            return false unless within_date_range?(time)
            return false if partitioned? && !partitioned_hour?(time)
            !cap_met?(total, today)
          end

          # Set the optional "active" parameter to true or false if you already know
          def calculate_pressure(time, total, today, active=nil)
            return nil if active == false
            return nil unless active || calculate_active?(time,total,today)
            time = time.in_time_zone(time_zone)
            if daily_capped?
              if daily_cap_precludes_overall_cap?(time,total,today)
                calculate_overall_pressure(time, total)
              else
                calculate_today_pressure(time, today)
              end
            elsif overall_pressure_exists?
              calculate_overall_pressure(time, total)
            else
              (ideal_impressions_per_hour || 1.0).to_f
            end
          end

          private

          def in_ad_time_zone(time)
            if time.present?
              (time.is_a?(String) ? Time.parse(time) : time).in_time_zone(time_zone)
            end
          rescue
            nil
          end

          def start_in_time_zone
            in_ad_time_zone(start_datetime)
          end

          def end_in_time_zone
            in_ad_time_zone(end_datetime)
          end

          def daily_capped?
            !daily_cap.nil? && daily_cap >= 0
          end

          def overall_capped?
            !overall_cap.nil? && overall_cap >= 0
          end

          def overall_pressure_exists?
            overall_capped? && end_datetime.present?
          end

          def partitioned?
            !day_partitions.nil? && day_partitions.length == 24*7
          end

          def within_date_range?(time)
            return false if start_datetime.present? && time < start_in_time_zone
            return false if end_datetime.present? && time >= end_in_time_zone
            true
          end

          # Assume time is in the time zone of the ad.
          # Doesn't worry about whether or not the time is in the ad's date range.
          # Assumes ad is partitioned.
          def partitioned_hour?(time)
            day_partitions[(time.wday * 24) + time.hour] == 'T'
          end

          # Assume time is in the time zone of the ad.
          # Doesn't worry about whether or not the time is in the ad's date range.
          # Assumes ad is partitioned.
          # Returns true if there is any active partition the day of the given time.
          def partitioned_day?(time)
            day_partitions[(time.wday) * 24, 24].include?('T')
          end

          # Assumes time is in the time zone of the ad.
          # Doesn't worry about date range or day partitions.
          def cap_met?(total_impressed, today_impressed)
            return true if daily_capped? && (daily_cap <= today_impressed)
            return true if overall_capped? && (overall_cap <= total_impressed)
            false
          end

          # Assumes time is in time_zone of the ad.
          # Returns true if there's no way we can hit the overall cap
          #  without busting the daily cap.
          def daily_cap_precludes_overall_cap?(time,total_impressed,today_impressed)
            return false unless daily_capped? && overall_capped?
            return false unless self.end_datetime.present?
            a = remaining_impressions_via_daily_cap(time, today_impressed)
            b = remaining_impressions_via_overall_cap(total_impressed)
            a < b
          end

          def remaining_impressions_via_overall_cap(total_impressed)
            [overall_cap - total_impressed, 0].max
          end

          def remaining_impressions_today(today_impressed)
            [daily_cap - today_impressed, 0].max
          end

          def remaining_impressions_via_daily_cap(time, today_impressed)
            days = remaining_days(time) - 1 # exclude today
            daily_cap * days + remaining_impressions_today(today_impressed)
          end

          # Assumes time is in time_zone of the ad.
          # Assume daily_cap is present.
          def calculate_today_pressure(time, today_impressed)
            hours = remaining_hours_today(time)
            if hours <= 0
              0.0
            else
              impressions = remaining_impressions_today(today_impressed)
              2 * impressions / hours.to_f
            end
          end

          # Assumes time is in time_zone of the ad.
          # Assume overall_cap is present.
          # Assume end_datetime is present.
          def calculate_overall_pressure(time, total_impressed)
            hours = remaining_hours(time)
            if hours <= 0
              0.0
            else
              impressions = remaining_impressions_via_overall_cap(total_impressed)
              impressions / hours.to_f
            end
          end

          # remaining_days : the total integer number of days that an ad will run
          #                  (even for part of the day) between now and the
          #                  end_datetime.
          # Assume all dates/times are in the time_zone of the ad.
          # Assume end_datetime is present.
          def remaining_days(time)
            ending = end_in_time_zone
            beginning = [time, start_in_time_zone].compact.max
            return 0 unless beginning < ending
            if partitioned?
              end_of_beginning_week = beginning_of_week(beginning) + 7.days
              beginning_of_end_week = beginning_of_week(ending)

              if end_of_beginning_week < beginning_of_end_week
                head_days = partitioned_days(beginning, end_of_beginning_week)
                tail_days = partitioned_days(beginning_of_end_week, ending)
                whole_weeks = (beginning_of_end_week-end_of_beginning_week) / 7.days
                head_days + (whole_weeks * days_per_week) + tail_days
              else
                partitioned_days(beginning, ending)
              end
            else
              (ending.beginning_of_day.to_datetime -
               beginning.beginning_of_day.to_datetime) + 1
            end
          end

          # remaining_hours : the total number of hours that an ad will run from now
          #                   to the end_datetime, taking day parting into account.
          # Assume all dates/times are in the time_zone of the ad.
          def remaining_hours(time)
            ending = end_in_time_zone
            beginning = [time, start_in_time_zone].compact.max
            return 0 unless beginning < ending
            if partitioned?

              end_of_beginning_week = beginning_of_week(beginning) + 7.days
              beginning_of_end_week = beginning_of_week(ending)

              if end_of_beginning_week < beginning_of_end_week
                head_hours = partitioned_hours(beginning, end_of_beginning_week)
                tail_hours = partitioned_hours(beginning_of_end_week, ending)
                whole_weeks = (beginning_of_end_week-end_of_beginning_week) / 7.days
                head_hours + (whole_weeks * hours_per_week) + tail_hours
              else
                partitioned_hours(beginning, ending)
              end
            else
              actual_hours(beginning, ending)
            end
          end

          # remaining_hours_today : the total number of hours that an ad will run
          #                         between now and the end of the day, taking day
          #                         parting into account.
          # Assume all dates/times are in the time_zone of the ad.
          def remaining_hours_today(time)
            beginning = [time, start_in_time_zone].compact.max
            ending = [time.beginning_of_day + 1.day, end_in_time_zone].compact.min
            return 0 unless beginning < ending
            if partitioned?
              partitioned_hours(beginning, ending)
            else
              actual_hours(beginning, ending)
            end
          end

          # Assume time is in the time_zone of the ad.
          # Assume a week begins on Sunday.
          def beginning_of_week(time)
            recent_monday = time.monday
            sunday_before_recent_monday = recent_monday - 1.day
            if (time - sunday_before_recent_monday) < 7.days
              sunday_before_recent_monday
            else
              sunday_before_recent_monday + 7.days
            end
          end

          def beginning_of_hour(time)
            time.change(:min => 0, :sec => 0, :usec => 0)
          end

          # Assume beginning and ending are in the ad's time_zone.
          # Assume beginning and ending are within the ad's date range.
          # Assume ad is partitioned.
          def partitioned_hours(beginning, ending)
            return 0 unless beginning < ending
            total = 0.0
            this_hour = beginning_of_hour(beginning)
            last_hour = beginning_of_hour(ending)
            if this_hour.to_i == last_hour.to_i
              if partitioned_hour?(this_hour)
                total = actual_hours(beginning, ending)
              end
            else
              next_hour = this_hour + 1.hour
              if partitioned_hour?(this_hour)
                total += actual_hours(beginning, next_hour)
              end
              each_hour(next_hour, last_hour) do |hour|
                total += 1 if partitioned_hour?(hour)
              end
              if partitioned_hour?(last_hour)
                total += actual_hours(last_hour, ending)
              end
            end
            total
          end

          # Assume beginning and ending are in the ad's time_zone.
          # Assume beginning and ending are within the ad's date range.
          # Assume ad is partitioned.
          # Assume beginning and ending are within a week of each other.
          # Computes integer number of days where any part of the day is active.
          def partitioned_days(beginning, ending)
            return 0 unless beginning < ending

            end_of_beginning_day = beginning.beginning_of_day + 1.day
            beginning_of_end_day = ending.beginning_of_day

            if end_of_beginning_day < beginning_of_end_day
              days = 0
              days += 1 if partitioned_hours(beginning, end_of_beginning_day) > 0
              days += 1 if partitioned_hours(beginning_of_end_day, ending) > 0
              each_day(end_of_beginning_day, beginning_of_end_day) do |day|
                days += 1 if partitioned_day?(day)
              end
              days
            else
              (partitioned_hours(beginning,ending) > 0) ? 1 : 0
            end
          end

          def each_day(beginning, ending)
            time = beginning.clone
            while (time < ending)
              yield time
              time += 1.day
            end
          end

          def each_hour(beginning, ending)
            time = beginning.clone
            while(time < ending)
              yield time
              time += 1.hour
            end
          end

          def actual_hours(beginning, ending)
            (ending.to_f - beginning.to_f) / 3600
          end

          # Assumes ad is partitioned.
          def days_per_week
            (0..6).map{|d| day_partitions[d*24,24].include?('T') ? 1 : 0 }.sum
          end

          # Assumes ad is partitioned.
          def hours_per_week
            day_partitions.count("T")
          end
        end
      end
    end
  end
end