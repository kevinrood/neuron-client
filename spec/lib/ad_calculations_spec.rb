
module Neuron
  module Client

    class FakeAd 
      include AdCalculations
      attr_accessor :start_datetime, :end_datetime, :time_zone, :day_partitions,
        :daily_cap, :overall_cap, :ideal_impressions_per_hour, :total_impressed,
        :today_impressed
      def initialize(opts={})
        opts.each { |sym, value| self.send("#{sym}=", value) }
        self.time_zone ||= "Beijing"
        self.total_impressed ||= 0
        self.today_impressed ||= 0
      end
    end



    describe AdCalculations do

      context "given an Ad with date range Sat, 01 Jan 2011, 00:00 -> Tue, 01 Feb 2011, 12:00; Beijing time; Day parted for 9:00 - 17:00, M-F; Daily cap of 10; Overall cap of 100; total_impressed of 50; today_impressed of 5" do
        before(:each) do
          @ad = FakeAd.new(
            :start_datetime => Time.new(2011,1,1,0,0,0,"+08:00"),
            :end_datetime => Time.new(2011,2,1,12,0,0,"+08:00"),
            :time_zone => "Beijing",
            :day_partitions => "F"*24 + ("F"*9 + "T"*8 + "F"*7)*5 + "F"*24,
            :daily_cap => 10,
            :overall_cap => 100,
            :ideal_impressions_per_hour => nil,
            :total_impressed => 50,
            :today_impressed => 5
          )
        end
        it "should be inactive on December 10th, 2010" do
          Timecop.freeze(Time.new(2010,12,10)) do
            @ad.active?.should be_false
          end
        end
        it "should be inactive on January 1st, 2011" do
          Timecop.freeze(Time.new(2011,1,1,10,0,0,"+08:00")) do
            @ad.active?.should be_false
          end
        end
        it "should be inactive on January 3rd, 2011 at 5:00 AM" do
          Timecop.freeze(Time.new(2011,1,3,5,0,0,"+08:00")) do
            @ad.active?.should be_false
          end
        end
        context "on January 3rd, 2011 at 10:00 AM" do
          before(:each) { Timecop.freeze(Time.new(2011,1,3,10,0,0,"+08:00")) }
          after(:each) { Timecop.return }
          it "should be active" do
            @ad.active?.should be_true
          end
          it "should have a pressure of 10/7" do
            @ad.pressure.should == 10 / 7.0
          end
        end
        context "on January 3rd, 2011 at 16:00" do
          before(:each) { Timecop.freeze(Time.new(2011,1,3,16,0,0,"+08:00")) }
          after(:each) { Timecop.return }
          it "should be active" do
            @ad.active?.should be_true
          end
          it "should have a pressure of 10/1" do
            @ad.pressure.should == 10
          end
        end
        context "on January 27th, 2011 at 16:00" do
          before(:each) { Timecop.freeze(Time.new(2011,1,27,16,0,0,"+08:00")) }
          after(:each) { Timecop.return }
          it "should be active" do
            @ad.active?.should be_true
          end
          it "should have a pressure of 50/20" do
            @ad.pressure.should == 50 / 20.0
          end
        end
        it "should be inactive on February 1st, 2011 at 13:00" do
          Timecop.freeze(Time.new(2011,2,1,13,0,0,"+08:00")) do
            @ad.active?.should be_false
          end
        end
      end

      describe ".active?" do
        it "should call calculate_active?" do
          @ad = FakeAd.new
          @ad.should_receive(:calculate_active?).and_return(:result)

          @ad.active?.should == :result
        end
      end

      describe ".pressure" do
        it "should call calculate_pressure" do
          @ad = FakeAd.new
          @ad.should_receive(:calculate_pressure).and_return(:result)

          @ad.pressure.should == :result
        end
      end

      describe ".calculate_active?(time, total_impressed, today_impressed)" do
        it "should have specs"
      end

      describe ".calculate_pressure(time, total_impressed, today_impressed, active=nil)" do
        it "should have some specs related to when 'active' is passed in"
        context "when daily_cap is present" do
          context "and daily_cap precludes overall_cap from being met" do
            it "should calculate the overall pressure" do
              ad = FakeAd.new(:daily_cap => 10)
              ad.stub(:daily_cap_precludes_overall_cap?).and_return(true)
              ad.should_receive(:calculate_overall_pressure)
              ad.should_not_receive(:calculate_today_pressure)

              ad.calculate_pressure(Time.now, 50, 5)
            end
          end
          context "and daily_cap does not preclude the overall_cap from being met" do
            it "should calculate the pressure for just today" do
              ad = FakeAd.new(:daily_cap => 10)
              ad.stub(:daily_cap_precludes_overall_cap?).and_return(false)
              ad.should_not_receive(:calculate_overall_pressure)
              ad.should_receive(:calculate_today_pressure)

              ad.calculate_pressure(Time.now, 50, 5)
            end
          end
        end
        context "when daily_cap is not present" do
          context "when overall_cap is blank or end_datetime is blank" do
            it "should use the ideal_impressions_per_hour" do
              ad = FakeAd.new(:overall_cap => 100, :ideal_impressions_per_hour => 99.9)
              ad.should_not_receive(:calculate_overall_pressure)
              ad.should_not_receive(:calculate_today_pressure)

              ad.calculate_pressure(Time.now, 50, 5).should == 99.9
            end
          end
          context "when overall_cap is not blank and end_datetime is not blank" do
            it "should calculate the overall pressure" do
              ad = FakeAd.new(:overall_cap => 100, :end_datetime => Time.now + 1.month)
              ad.should_receive(:calculate_overall_pressure)
              ad.should_not_receive(:calculate_today_pressure)

              ad.calculate_pressure(Time.now, 50, 5)
            end
          end
        end
      end


      describe ".start_in_time_zone" do
        it "should return start_datetime, time zone adjusted" do
          result = FakeAd.new(
            :start_datetime => Time.utc(2011, 2, 1, 1, 59),
            :time_zone => 'Eastern Time (US & Canada)'
          ).send(:start_in_time_zone)
          formatted_result = "#{result.time.strftime('%a, %d %b %Y %H:%M:%S')} #{result.zone} #{result.formatted_offset}"

          formatted_result.should == "Mon, 31 Jan 2011 20:59:00 EST -05:00"
        end
      end

      describe ".end_in_time_zone" do
        context "when end_datetime is present" do
          it "should return end_datetime, time zone adjusted" do
            result = FakeAd.new(
              :end_datetime => Time.utc(2011, 2, 1, 1, 59),
              :time_zone => 'Eastern Time (US & Canada)'
            ).send(:end_in_time_zone)
            formatted_result = "#{result.time.strftime('%a, %d %b %Y %H:%M:%S')} #{result.zone} #{result.formatted_offset}"

            formatted_result.should == "Mon, 31 Jan 2011 20:59:00 EST -05:00"
          end
        end
        context "when end_datetime is not present" do
          it "should return nil" do
            FakeAd.new(:end_datetime => nil).send(:end_in_time_zone).should be_nil
          end
        end
      end

      describe ".daily_capped?" do
        it "should be false when daily_cap is nil" do
          FakeAd.new(:daily_cap => nil).send(:daily_capped?).should be_false
        end
        it "should be true when daily_cap is a positive integer > zero" do
          FakeAd.new(:daily_cap => 42).send(:daily_capped?).should be_true
        end
      end

      describe ".overall_capped?" do
        it "should be false when overall_cap is nil" do
          FakeAd.new(:overall_cap => nil).send(:overall_capped?).should be_false
        end
        it "should be true when overall_cap is a positive integer > zero" do
          FakeAd.new(:overall_cap => 42).send(:overall_capped?).should be_true
        end
      end

      describe ".partitioned?" do
        it "should be false when day_partitions is nil" do
          FakeAd.new(:day_partitions => nil).send(:partitioned?).should be_false
        end
        it "should be true when day_partitions is 168 character string of Ts and Fs." do
          p = ("T"*100 + "F"*68).split('').shuffle.join
          FakeAd.new(:day_partitions => p).send(:partitioned?).should be_true
        end
      end
      
      def within_date_range
        FakeAd.new(:start_datetime => @start, :end_datetime => @end).send(:within_date_range?, @now)
      end

      describe ".within_date_range?(date)" do
        before(:all) do
          @now = Time.now
        end
        context "when ad has no start date" do
          context "when ad has no end date" do
            it "should return true" do
              @start = nil
              @end = nil
              within_date_range.should be_true
            end
          end
          context "when before ad's end date" do
            it "should return true" do
              @start = nil
              @end = @now + 1.day
              within_date_range.should be_true
            end
          end
          context "when on or beyond ad's end date" do
            it "should return false" do
              @start = nil
              @end = @now
              within_date_range.should be_false
              @end = @now - 1.day
              within_date_range.should be_false
            end
          end
        end
        context "when before ad's start date" do
          context "when ad has no end date" do
            it "should return false" do
              @start = @now + 1.day
              @end = nil
              within_date_range.should be_false
            end
          end
          context "when before ad's end date" do
            it "should return false" do
              @start = @now + 1.day
              @end = @start + 1.day
              within_date_range.should be_false
            end
          end
        end
        context "when on or beyond ad's start date" do
          context "when ad has no end date" do
            it "should return true" do
              @start = @now
              @end = nil
              within_date_range.should be_true
              @start = @now - 1.day
              within_date_range.should be_true
            end
          end
          context "when before ad's end date" do
            it "should return true" do
              @start = @now
              @end = @now + 1.day
              within_date_range.should be_true
              @start = @now - 1.day
              within_date_range.should be_true
            end
          end
          context "when on or beyond ad's end date" do
            it "should return false" do
              @start = @now
              @end = @now
              within_date_range.should be_false
              @start = @now - 2.days
              @end = @now
              within_date_range.should be_false
              @end = @now - 1.day
              within_date_range.should be_false
            end
          end
        end
      end

      describe ".partitioned_hour?(time)" do
        context "when day partitions exist" do
          before(:all) do
            @ad = FakeAd.new(:day_partitions => [
              "TTTTTTTTTTFTTTTTTTTTTTTT", # Sunday
              "TTTTTTTTTTTTTTTFTTTTTTTT", # Monday
              "FTTTTTTTTTTTTTTTTTTTTTTT", # Tuesday
              "TTTTTFTTTTTTTTTTTTTTTTTT", # Wednesday
              "TTTTTTTTTTTTTTTTTTTTFTTT", # Thursday
              "TTTTTTTTTTTTTTTTTTTTTTTF", # Friday
              "TTTTTTTTTTTTFTTTTTTTTTTT"  # Saturday
            ].join)
          end
          context "when on Sunday" do
            context "when on day partition" do
              it "should return true" do
                time = Chronic.parse('Sunday @ 9 am')
                @ad.send(:partitioned_hour?, time).should be_true
              end
            end
            context "when not on day partition" do
              it "should return false" do
                time = Chronic.parse('Sunday @ 10 am')
                @ad.send(:partitioned_hour?, time).should be_false
              end
            end
          end
          context "when on Monday" do
            context "when on day partition" do
              it "should return true" do
                time = Chronic.parse('Monday @ 2 pm')
                @ad.send(:partitioned_hour?, time).should be_true
              end
            end
            context "when not on day partition" do
              it "should return false" do
                time = Chronic.parse('Monday @ 3 pm')
                @ad.send(:partitioned_hour?, time).should be_false
              end
            end
          end
          context "when on Friday" do
            context "when on day partition" do
              it "should return true" do
                time = Chronic.parse('Friday @ 10 pm')
                @ad.send(:partitioned_hour?, time).should be_true
              end
            end
            context "when not on day partition" do
              it "should return false" do
                time = Chronic.parse('Friday @ 11 pm')
                @ad.send(:partitioned_hour?, time).should be_false
              end
            end
          end
          context "when on Saturday" do
            context "when on day partition" do
              it "should return true" do
                time = Chronic.parse('Saturday @ 1 pm')
                @ad.send(:partitioned_hour?, time).should be_true
              end
            end
            context "when not on day partition" do
              it "should return false" do
                time = Chronic.parse('Saturday @ 12 pm')
                @ad.send(:partitioned_hour?, time).should be_false
              end
            end
          end
        end
      end

      def partitioned_day?(time)
        nine_to_five = "F"*9 + "T"*8 + "F"*7
        no_hours = "F" * 24
        ad = FakeAd.new(:day_partitions => [nine_to_five, nine_to_five, no_hours, nine_to_five, nine_to_five, nine_to_five, no_hours].join)
        ad.send(:partitioned_day?, time)
      end
      describe ".partitioned_day?(time)" do
        context "when ad is partitioned from 9-5, every day of the week except Tuesday and Saturday" do
          it "should return true on Sunday @ 5 am" do
            partitioned_day?( Chronic.parse('Sunday @ 5 am') ).should be_true
          end
          it "should return true on Sunday @ 10 am" do
            partitioned_day?( Chronic.parse('Sunday @ 10 am') ).should be_true
          end
          it "should return true on Sunday @ 10 pm" do
            partitioned_day?( Chronic.parse('Sunday @ 10 pm') ).should be_true
          end
          it "should return true on Monday @ 5 am" do
            partitioned_day?( Chronic.parse('Monday @ 5 am') ).should be_true
          end
          it "should return false on Tuesday @ 5 am" do
            partitioned_day?( Chronic.parse('Tuesday @ 5 am') ).should be_false
          end
          it "should return false on Tuesday @ 10 am" do
            partitioned_day?( Chronic.parse('Tuesday @ 10 am') ).should be_false
          end
          it "should return true on Wednesday @ 5 am" do
            partitioned_day?( Chronic.parse('Wednesday @ 5 am') ).should be_true
          end
          it "should return true on Thursday @ 5 am" do
            partitioned_day?( Chronic.parse('Thursday @ 5 am') ).should be_true
          end
          it "should return true on Friday @ 5 am" do
            partitioned_day?( Chronic.parse('Friday @ 5 am') ).should be_true
          end
          it "should return false on Saturday @ 5 am" do
            partitioned_day?( Chronic.parse('Saturday @ 5 am') ).should be_false
          end
        end
      end

      describe ".cap_met?(total_impressed, today_impressed)" do
        context "when not daily capped" do
          context "and not overall capped" do
            it "should return false" do
              FakeAd.new(:daily_cap => nil, :overall_cap => nil).send(:cap_met?, 10, 10).should be_false
            end
          end
          context "and overall cap is 10" do
            before(:each) do
              @ad = FakeAd.new(:daily_cap => nil, :overall_cap => 10)
            end
            context "and total_impressed = 9" do
              it "should return false" do
                @ad.send(:cap_met?, 9, 0).should be_false
              end
            end
            context "and total_impressed = 10" do
              it "should return true" do
                @ad.send(:cap_met?, 10, 0).should be_true
              end
            end
            context "and total_impressed = 11" do
              it "should return true" do
                @ad.send(:cap_met?, 11, 0).should be_true
              end
            end
          end
        end
        context "when daily cap is 10" do
          context "and not overall capped" do
            before(:each) do
              @ad = FakeAd.new(:daily_cap => 10, :overall_cap => nil)
            end
            context "and today_impressed = 9" do
              it "should return false" do
                @ad.send(:cap_met?, 0, 9).should be_false
              end
            end
            context "and today_impressed = 10" do
              it "should return true" do
                @ad.send(:cap_met?, 0, 10).should be_true
              end
            end
            context "and today_impressed = 11" do
              it "should return true" do
                @ad.send(:cap_met?, 0, 11).should be_true
              end
            end
          end
          context "and overall cap is 100" do
            before(:each) do
              @ad = FakeAd.new(:daily_cap => 10, :overall_cap => 100)
            end
            context "and total < 100, today < 10" do
              it "should return false" do
                @ad.send(:cap_met?, 99, 9).should be_false
              end
            end
            context "and total < 100, today = 10" do
              it "should return true" do
                @ad.send(:cap_met?, 99, 10).should be_true
              end
            end
            context "and total = 100, today < 10" do
              it "should return true" do
                @ad.send(:cap_met?, 100, 9).should be_true
              end
            end
            context "and total = 100, today = 10" do
              it "should return true" do
                @ad.send(:cap_met?, 100, 10).should be_true
              end
            end
          end
        end
      end

      def precluded
        @time = Time.now
        @total = 500
        @today = 100
        ad = FakeAd.new(:daily_cap => @daily_cap, :overall_cap => @overall_cap, :end_datetime => @end_datetime)
        ad.stub(:remaining_impressions_via_daily_cap).with(@time, @today).and_return(@remaining_via_daily_cap)
        ad.stub(:remaining_impressions_via_overall_cap).with(@total).and_return(@remaining_via_overall_cap)
        ad.send(:daily_cap_precludes_overall_cap?, @time, @total, @today)
      end
      describe ".daily_cap_precludes_overall_cap?(time, total_impressed, today_impressed)" do
        context "when ad has no daily cap" do
          it "should return false" do
            @daily_cap = nil
            @overall_cap = 1
            precluded.should be_false
          end
        end
        context "when ad has no overall cap" do
          it "should return false" do
            @daily_cap = 1
            @overall_cap = nil
            precluded.should be_false
          end
        end
        context "when ad has no end date/time" do
          it "should return false" do
            @daily_cap = 1
            @overall_cap = 1
            @end_datetime = nil
            precluded.should be_false
          end
        end
        context "when ad's daily cap is 10, overall cap is 100, and end datetime is present" do
          before(:each) { @daily_cap = 10; @overall_cap = 100; @end_datetime = Time.now + 10.days }
          context "when remaining_impressions_via_daily_cap < remaining_impressions_via_overall_cap" do
            it "returns true" do
              @remaining_via_daily_cap = 1
              @remaining_via_overall_cap = 2
              precluded.should be_true
            end
          end
          context "when remaining_impressions_via_daily_cap = remaining_impressions_via_overall_cap" do
            it "returns false" do
              @remaining_via_daily_cap = 1
              @remaining_via_overall_cap = 1
              precluded.should be_false
            end
          end
          context "when remaining_impressions_via_daily_cap > remaining_impressions_via_overall_cap" do
            it "returns false" do
              @remaining_via_daily_cap = 2
              @remaining_via_overall_cap = 1
              precluded.should be_false
            end
          end
        end
      end

      describe ".remaining_impressions_via_overall_cap(total_impressed)" do
        context "when overall_cap = 100" do
          before(:each) { @ad = FakeAd.new(:overall_cap => 100) }
          context "when total_impressed = 0" do
            it "returns 100" do
              @ad.send(:remaining_impressions_via_overall_cap, 0).should == 100
            end
          end
          context "when total_impressed = 99" do
            it "returns 1" do
              @ad.send(:remaining_impressions_via_overall_cap, 99).should == 1
            end
          end
          context "when total_impressed = 100" do
            it "returns 0" do
              @ad.send(:remaining_impressions_via_overall_cap, 100).should == 0
            end
          end
          context "when total_impressed = 101" do
            it "returns 0" do
              @ad.send(:remaining_impressions_via_overall_cap, 101).should == 0
            end
          end
        end
      end

      describe ".remaining_impressions_today(today_impressed)" do
        context "when daily_cap = 100" do
          before(:each) { @ad = FakeAd.new(:daily_cap => 100) }
          context "when today_impressed = 0" do
            it "returns 100" do
              @ad.send(:remaining_impressions_today, 0).should == 100
            end
          end
          context "when today_impressed = 99" do
            it "returns 1" do
              @ad.send(:remaining_impressions_today, 99).should == 1
            end
          end
          context "when today_impressed = 100" do
            it "returns 0" do
              @ad.send(:remaining_impressions_today, 100).should == 0
            end
          end
          context "when today_impressed = 101" do
            it "returns 0" do
              @ad.send(:remaining_impressions_today, 101).should == 0
            end
          end
        end
      end

      describe ".remaining_impressions_via_daily_cap(time, today_impressed)" do
        context "when daily_cap is 100, ad has 5 days remaining (including today), and 30 remaining impressions today" do
          it "returns 430" do
            ad = FakeAd.new(:daily_cap => 100)
            ad.stub(:remaining_days).with(:time).and_return(5)
            ad.stub(:remaining_impressions_today).with(:today_impressed).and_return(30)

            ad.send(:remaining_impressions_via_daily_cap, :time, :today_impressed).should == 430
          end
        end
      end

      describe ".calculate_today_pressure(time, today_impressed)" do
        context "when there are 3 hours and 12 impressions remaining today" do
          it "should return a pressure of 8 (impressions/hr)" do
            ad = FakeAd.new
            ad.stub(:remaining_hours_today).with(:time).and_return(3)
            ad.stub(:remaining_impressions_today).with(:today_impressed).and_return(12)

            ad.send(:calculate_today_pressure, :time, :today_impressed).should == 8
          end
        end
        context "when there are 0 hours and 12 impressions remaining today" do
          it "should return a pressure of 0 (impressions/hr)" do
            ad = FakeAd.new
            ad.stub(:remaining_hours_today).with(:time).and_return(0)
            ad.stub(:remaining_impressions_today).with(:today_impressed).and_return(12)

            ad.send(:calculate_today_pressure, :time, :today_impressed).should == 0
          end
        end
      end

      describe ".calculate_overall_pressure(time, total_impressed)" do
        context "when there are 3 hours and 12 impressions remaining overall" do
          it "should return a pressure of 4 (impressions/hr)" do
            ad = FakeAd.new
            ad.stub(:remaining_hours).with(:time).and_return(3)
            ad.stub(:remaining_impressions_via_overall_cap).with(:total_impressed).and_return(12)

            ad.send(:calculate_overall_pressure, :time, :total_impressed).should == 4
          end
        end
        context "when there are 0 hours and 12 impressions remaining overall" do
          it "should return a pressure of 0 (impressions/hr)" do
            ad = FakeAd.new
            ad.stub(:remaining_hours).with(:time).and_return(0)
            ad.stub(:remaining_impressions_via_overall_cap).with(:total_impressed).and_return(12)

            ad.send(:calculate_overall_pressure, :time, :total_impressed).should == 0
          end
        end
      end

      def remaining_days(time)
        FakeAd.new(
          :start_datetime => @start,
          :end_datetime => @end,
          :day_partitions => @day_partitions).send(:remaining_days, time.in_time_zone("Beijing"))
      end
      describe ".remaining_days(time)" do
        context "when time is on or after ad's end_datetime" do
          it "should return zero" do
            @start = nil
            @end = Time.at(1234567890)
            remaining_days(@end).should == 0
            remaining_days(@end + 1.day).should == 0
          end
        end
        context "when time is before ad's end_datetime" do
          context "and ad is not day-partitioned" do
            before(:each) { @day_partitions = nil }
            context "and time is before ad's start_datetime" do
              it "returns the number of days between the ad's start and end, including partial days on either end" do
                @start = Time.parse("2011-11-11 11:11 +08:00")
                @end = @start + 2.days
                remaining_days(@start - 1.week).should == 3
              end
            end
            context "and time is after the ad's start_datetime" do
              it "should return the number of days between the given time and the ad's end" do
                @start = Time.parse("2011-11-11 11:11 +08:00")
                @time = @start + 1.day
                @end = @time + 1.day
                remaining_days(@time).should == 2
              end
              context "and the ad's end occurs at midnight" do
                it "should return the number of days between the given time and the ad's end, not counting the morning of the final date" do
                  @start = Time.parse("2011-11-11 11:11 +08:00")
                  @time = @start + 1.day
                  @end = @time.end_of_day + 1.day
                  remaining_days(@time).should == 2
                end
              end
              context "and the time is on the same day as the ad's end" do
                it "should return one" do
                  @start = Time.parse("2011-11-11 11:11 +08:00")
                  @time = @start + 1.day
                  @end = @time + 1.hour
                  remaining_days(@time).should == 1
                end
              end
              context "and the ad's end is at midnight the night after the given time" do
                it "should return one" do
                  @start = Time.parse("2011-11-11 11:11 +08:00")
                  @time = @start + 1.day
                  @end = @time.end_of_day
                  remaining_days(@time).should == 1
                end
              end
            end
          end
          context "when ad is partitioned with the first 12 hours of each weekday active, and the last 12 and the whole weekend inactive" do
            before(:all) do
              @time_zone = "Beijing"
              Time.zone = @time_zone
              Chronic.time_class = Time.zone
              @day_partitions = "F"*24 + ("T"*12 + "F"*12) * 5 + "F"*24
            end
            context "when time is before ad's start_datetime, and date range is from Monday @ 9:30am to Friday @ 6pm" do
              it "should return 5 days" do
                @start = Chronic.parse "Monday @ 9:30am"
                @end = Chronic.parse "Friday @ 6pm"
                remaining_days(Chronic.parse("1 month ago")).should == 5
              end
            end
            context "when time is before ad's start_datetime, and date range is from Monday @ 6pm to Friday @ 9:30am" do
              it "should return 4 days" do
                @start = Chronic.parse "Monday @ 6pm"
                @end = Chronic.parse "Friday @ 9:30am"
                remaining_days(Chronic.parse("1 month ago")).should == 4
              end
            end
            context "when time is before ad's start_datetime, and date range is from Monday @ 6pm to Friday morning @ 12am" do
              it "should return 4 days" do
                @start = Chronic.parse "Monday @ 6pm"
                @end = Chronic.parse "Friday @ 12am"
                remaining_days(Chronic.parse("1 month ago")).should == 3
              end
            end
            context "when time is before ad's start_datetime, and date range is from Monday @ 6pm to Three Mondays later @ 6am" do
              it "should return 15 hours" do
                @start = Chronic.parse "Monday @ 6pm"
                @end = Chronic.parse("Monday @ 6am") + 3.weeks
                remaining_days(Chronic.parse("1 month ago")).should == 15
              end
            end
            context "when the date range is really long" do
              it "should not take a long time to compute" do
                @start = Chronic.parse "2010-01-01 1am"
                @end = Chronic.parse "2020-01-07 5am"
                started = Time.now.to_f
                remaining_days(Chronic.parse("2009-12-31 11pm")).should == 2613
                finished = Time.now.to_f
                (finished - started).should > 0.0
                (finished - started).should < 0.1
              end
            end
          end
        end
      end

      describe ".remaining_hours(time)" do
        context "when time is on or after ad's end_datetime" do
          it "should return zero" do
            @end = Time.at(1234567890)
            a = FakeAd.new(:end_datetime => @end)
            a.send(:remaining_hours, @end).should == 0
            a.send(:remaining_hours, @end + 1.day).should == 0
          end
        end
        context "when time is before ad's end_datetime" do
          context "when ad is not day-partitioned" do
            context "when time is before ad's start_datetime" do
              it "returns the number of hours between the ad's start and end" do
                @end = Time.at(1234567890)
                a = FakeAd.new(:start_datetime => @end - 3.days, :end_datetime => @end, :day_partitions => nil)
                a.send(:remaining_hours, @end - 5.days).should == 24*3
              end
            end
            context "when time is after the ad's start_datetime" do
              it "should return the number of hours between the given time and the ad's end" do
                @end = Time.at(1234567890)
                a = FakeAd.new(:start_datetime => @end - 5.days, :end_datetime => @end, :day_partitions => nil)
                a.send(:remaining_hours, @end - 3.days).should == 24*3
              end
            end
          end
          context "when ad is partitioned with the first 12 hours of each day active, and the last 12 inactive" do
            before(:all) do
              @time_zone = "Beijing"
              Time.zone = @time_zone
              Chronic.time_class = Time.zone
              @day_partitions = ("T"*12 + "F"*12) * 7
            end
            context "when time is before ad's start_datetime, and date range is from Monday @ 9:30am to Friday @ 6pm" do
              it "should return 50.5 hours" do
                a = FakeAd.new(:start_datetime => Chronic.parse("Monday @ 9:30am"),
                                :end_datetime => Chronic.parse("Friday @ 6pm"),
                                :day_partitions => @day_partitions)
                a.send(:remaining_hours, Chronic.parse("1 month ago")).should == 50.5
              end
            end
            context "when time is before ad's start_datetime, and date range is from Monday @ 6pm to Friday @ 9:30am" do
              it "should return 45.5 hours" do
                a = FakeAd.new(:start_datetime => Chronic.parse("Monday @ 6pm"),
                                :end_datetime => Chronic.parse("Friday @ 9:30am"),
                                :day_partitions => @day_partitions)
                a.send(:remaining_hours, Chronic.parse("1 month ago")).should == 45.5
              end
            end
            context "when time is before ad's start_datetime, and date range is from Monday @ 6pm to Three Mondays later @ 6am" do
              it "should return 246 (12 * 7 * 3 - 6) hours" do
                a = FakeAd.new(:start_datetime => Chronic.parse("Monday @ 6pm"),
                                :end_datetime => Chronic.parse("Monday @ 6am") + 3.weeks,
                                :day_partitions => @day_partitions)
                a.send(:remaining_hours, Chronic.parse("1 month ago")).should == 12 * 7 * 3 - 6
              end
            end
            context "when the date range is really long" do
              it "should not take a long time to compute" do
                a = FakeAd.new(:start_datetime => Chronic.parse("2010-01-01 1am"),
                                :end_datetime => Chronic.parse("2020-01-07 5am"),
                                :day_partitions => @day_partitions)
                started = Time.now.to_f
                a.send(:remaining_hours, Chronic.parse("2009-12-31 11pm")).should == 43900
                finished = Time.now.to_f
                (finished - started).should > 0.0
                (finished - started).should < 0.1
              end
            end
          end
        end
      end

      def remaining_hours_today(time)
        @ad = FakeAd.new(
          :start_datetime => @start,
          :end_datetime => @end,
          :day_partitions => @day_partitions)
        @ad.send(:remaining_hours_today, time.in_time_zone(@time_zone))
      end
      describe ".remaining_hours_today(time)" do
        before(:all) do
          @time_zone = "Beijing"
          Time.zone = @time_zone
          Chronic.time_class = Time.zone
        end
        context "when ad is not day-partitioned" do
          before(:all) { @day_partitions = nil}
          context "when ad's start and end date/time are the same day" do
            before(:all) do
              @start = Chronic.parse('tomorrow @ 9am')
              @end = Chronic.parse('tomorrow @ 5pm')
            end
            context "when the given time is on a different day" do
              it "should return zero" do
                remaining_hours_today(@start - 2.days).should == 0
                remaining_hours_today(@end - 2.days).should == 0
              end
            end
            context "when the given time is on the same day, but before the start" do
              it "should return the full number of hours of the ad's range" do
                remaining_hours_today(@start - 5.hours).should == 8
              end
            end
            context 'when the given time is on the same day, within the date range' do
              it "should return the hours between the given time and the end" do
                remaining_hours_today(Chronic.parse('tomorrow @ noon')).should == 5
              end
            end
            context "when the given time is on the same day, but after the end" do
              it "should return zero" do
                remaining_hours_today(@end + 1.hour).should == 0
              end
            end
          end
          context "when the given time is at least 24 hours before the start time" do
            it "should return zero" do
              @start = Time.at(1234567890)
              @end = @start + 1.month
              remaining_hours_today(@start - 1.day).should == 0
            end
          end
          context "when the given time is at least 24 hours after the end time" do
            it "should return zero" do
              @start = Time.at(1234567890)
              @end = @start + 1.month
              remaining_hours_today(@end + 1.day).should == 0
            end
          end
          context "when the given time is after the the start_time" do
            context "and at least 24 hours before the end time" do
              it "should return the hours from the given time to midnight of that night" do
                @start = Chronic.parse("yesterday @ 3am")
                @time = Chronic.parse("today @ 8pm")
                @end = @time + 1.day
                remaining_hours_today(@time).should == 4
              end
            end
            context "and the ad's end comes before midnight of the given time" do
              context "and the given time is before the end time" do
                it "should return the hours between the given time and the end time" do
                  @start = Chronic.parse("yesterday @ 3am")
                  @time = Chronic.parse("today @ 8pm")
                  @end = @time + 2.hours
                  remaining_hours_today(@time).should == 2
                end
              end
              context "and the given time is after the end time" do
                it "should return zero" do
                  @start = Chronic.parse("yesterday @ 3am")
                  @time = Chronic.parse("today @ 8pm")
                  @end = @time - 2.hours
                  remaining_hours_today(@time).should == 0
                end
              end
              context "and the given time matches the end time" do
                it "should return zero" do
                  @start = Chronic.parse("yesterday @ 3am")
                  @time = Chronic.parse("today @ 8pm")
                  @end = @time
                  remaining_hours_today(@time).should == 0
                end
              end
            end
          end
        end
        context "when ad is partitioned with the first 12 hours of each day active, and the last 12 inactive" do
          before(:all) { @day_partitions = ("T"*12 + "F"*12) * 7}
          context "when ad's start and end date/time are the same day" do
            before(:all) do
              @start = Chronic.parse('tomorrow @ 9am')
              @end = Chronic.parse('tomorrow @ 5pm')
            end
            context "when the given time is on a different day" do
              it "should return zero" do
                remaining_hours_today(@start - 2.days).should == 0
                remaining_hours_today(@end - 2.days).should == 0
              end
            end
            context "when the given time is on the same day, but before the start" do
              it "should return the full number of hours of the ad's range" do
                remaining_hours_today(@start - 5.hours).should == 3
              end
            end
            context 'when the given time is on the same day, within the date range' do
              it "should return the hours between the given time and the end" do
                remaining_hours_today(Chronic.parse('tomorrow @ 11am')).should == 1
              end
            end
            context "when the given time is on the same day, but after the end" do
              it "should return zero" do
                remaining_hours_today(@end + 1.hour).should == 0
              end
            end
          end
          context "when the given time is at least 24 hours before the start time" do
            it "should return zero" do
              @start = Time.at(1234567890)
              @end = @start + 1.month
              remaining_hours_today(@start - 1.day).should == 0
            end
          end
          context "when the given time is at least 24 hours after the end time" do
            it "should return zero" do
              @start = Time.at(1234567890)
              @end = @start + 1.month
              remaining_hours_today(@end + 1.day).should == 0
            end
          end
          context "when the given time is after the the start_time" do
            context "and at least 24 hours before the end time" do
              it "should return the hours from the given time to midnight of that night" do
                @start = Chronic.parse("yesterday @ 3am")
                @time = Chronic.parse("today @ 7am")
                @end = @time + 1.day
                remaining_hours_today(@time).should == 5 #day part ends at noon
              end
            end
            context "and the ad's end comes before midnight of the given time" do
              context "and the given time is before the end time" do
                it "should return the hours between the given time and the end time" do
                  @start = Chronic.parse("yesterday @ 3am")
                  @time = Chronic.parse("today @ 10:30am")
                  @end = @time + 2.hours
                  remaining_hours_today(@time).should == 1.5 #day part ends at noon
                end
              end
              context "and the given time is after the end time" do
                it "should return zero" do
                  @start = Chronic.parse("yesterday @ 3am")
                  @time = Chronic.parse("today @ 7am")
                  @end = @time - 2.hours
                  remaining_hours_today(@time).should == 0
                end
              end
              context "and the given time matches the end time" do
                it "should return zero" do
                  @start = Chronic.parse("yesterday @ 3am")
                  @time = Chronic.parse("today @ 7am")
                  @end = @time
                  remaining_hours_today(@time).should == 0
                end
              end
            end
          end
        end
      end

      def beginning_of_week(time)
        FakeAd.new.send(:beginning_of_week, time)
      end
      describe ".beginning_of_week(time)" do
        context "time is on sunday morning at midnight" do
          it "should return an equivalent time" do
            time = Chronic.parse("Sunday @ 00:00")
            beginning_of_week(time).should == time
          end
        end
        context "time is on sunday at noon" do
          it "should return a time 12 hours before" do
            time = Chronic.parse("Sunday @ noon")
            beginning_of_week(time).should == time - 12.hours
          end
        end
        context "time is on monday at noon" do
          it "should return a time 12 hours and one day before" do
            time = Chronic.parse("Monday @ noon")
            beginning_of_week(time).should == time - (12.hours + 1.day)
          end
        end
        context "time is on tuesday at noon" do
          it "should return a time 12 hours and two days before" do
            time = Chronic.parse("Tuesday @ noon")
            beginning_of_week(time).should == time - (12.hours + 2.day)
          end
        end
        context "time is on wednesday at noon" do
          it "should return a time 12 hours and three days before" do
            time = Chronic.parse("Wednesday @ noon")
            beginning_of_week(time).should == time - (12.hours + 3.day)
          end
        end
        context "time is on thursday at noon" do
          it "should return a time 12 hours and four days before" do
            time = Chronic.parse("Thursday @ noon")
            beginning_of_week(time).should == time - (12.hours + 4.day)
          end
        end
        context "time is on friday at noon" do
          it "should return a time 12 hours and five days before" do
            time = Chronic.parse("Friday @ noon")
            beginning_of_week(time).should == time - (12.hours + 5.day)
          end
        end
        context "time is on saturday at noon" do
          it "should return a time 12 hours and six days before" do
            time = Chronic.parse("Saturday @ noon")
            beginning_of_week(time).should == time - (12.hours + 6.day)
          end
        end
      end

      def beginning_of_hour(time)
        FakeAd.new.send(:beginning_of_hour, time)
      end
      describe ".beginning_of_hour(time)" do
        before(:all) { @one_pm = Chronic.parse('1:00pm')}
        context "at 1:00 pm" do
          it "should return 1:00 pm" do
            beginning_of_hour(@one_pm).should == @one_pm
          end
        end
        context "at 1:01 pm" do
          it "should return 1:00 pm" do
            beginning_of_hour(@one_pm + 1.minute).should == @one_pm
          end
        end
        context "at 1:59:59.9 pm" do
          it "should return 1:00 pm" do
            beginning_of_hour(@one_pm + 59.minutes + 59.9.seconds).should == @one_pm
          end
        end
      end

      def partitioned_hours(beginning, ending)
        FakeAd.new(:day_partitions => @day_partitions).send(:partitioned_hours, beginning, ending)
      end
      describe ".partitioned_hours(beginning, ending)" do
        before(:all) do
          @time_zone = "Beijing"
          Time.zone = @time_zone
          Chronic.time_class = Time.zone
        end
        context "when ad is partitioned, active first 12 hours of every week day, inactive the last 12 hours and weekends" do
          before(:all) { @day_partitions = "F"*24 + ("T"*12 + "F"*12)*5 + "F"*24 }
          context "and beginning after ending" do
            it "should return zero" do
              partitioned_hours(Time.now, Time.now - 1.day).should == 0
            end
          end
          context "and beginning and ending are in the same hour" do
            context "and that hour is an active partition" do
              it "should return the time (in hours) from beginning to ending" do
                @start = Chronic.parse("Monday @ 9:10am")
                @end = Chronic.parse("Monday @ 9:50am")
                partitioned_hours(@start, @end).should == 40/60.0
              end
            end
            context "and that hour is an inactive partition" do
              it "should return zero" do
                @start = Chronic.parse("Monday @ 9:10pm")
                @end = Chronic.parse("Monday @ 9:50pm")
                partitioned_hours(@start, @end).should == 0
              end
            end
          end
          it "should have more specs"
        end
      end

      describe ".partitioned_days(beginning, ending)" do
        it "should have specs"
      end

      describe ".each_day(beginning, ending)" do
        it "should have specs"
      end

      describe ".each_hour(beginning, ending)" do
        it "should have specs"
      end

      describe ".actual_hours(beginning, ending)" do
        it "should have specs"
      end

      describe ".days_per_week" do
        it "should have specs"
      end

      describe ".hours_per_week" do
        it "should have specs"
      end

    end
  end
end

