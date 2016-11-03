require 'open-uri'
require 'json'
require 'dashing'
require 'date'
require 'time'
require 'logger'

url = "http://graphite.prod.aws.justgiving.service/"
LOG = Logger.new('/graphite/dashing2.log')
current = 0
last = 0

module GraphiteQuery

		def current_points(name, timeframe=nil, to, url)
			timeframe ||= '1min'
			current = query_current(name, timeframe, to, url)

			 points = []
		        count = 1

		       (current[:datapoints].select { |el| not el[0].nil? }).each do |item| #removes nil element from array and with new array then assigns each datapoint to a y value
		            points << { x: count, y: get_value(item)}
		            count += 1
		        end

		         current_value = points.inject(0){|sum, pos| sum += pos[:y]; sum}.round(2)

		        return current_value
		end

		def query_current(statname, timeframe, to, url)
			timeframe ||= "#{timeframe}"
			response_current = URI.parse("#{url}/render?format=json&target=#{statname}&from=#{timeframe}").read
	        result_current = JSON.parse(response_current, :symbolize_names => true)
	        current = result_current.first

	        return current
		end


	    def get_value(datapoint)

        	value = datapoint[0] || 0

        	return value.round(2)

    	end

		def last_points(name, timeframe=nil, to, url)
			timeframe ||= '1min'
			last = query_last(name, timeframe, to, url)

			  points_last = []
		        count = 1

		        (last[:datapoints].select { |el| not el[0].nil? }).each do |item| #removes nil element from array and with new array then assigns each datapoint to a y value
		            points_last << { x: count, y: get_value(item)}
		            count += 1
		        end
		          last_value = points_last.inject(0){|sum, pos| sum += pos[:y]; sum}.round(2)

		        return last_value
		end

		def query_last(statname, timeframe, to, url)
			timeframe ||= "#{timeframe}"
			response_last = URI.parse("#{url}/render/?from=#{timeframe}&target=timeShift(#{statname}%2C%22#{to}%22)&format=json").read
	        result_last = JSON.parse(response_last, :symbolize_names => true)
	        last = result_last.first
	        return last
		end

end

class Job
	include GraphiteQuery
end


def start_scheduler(title, statname, timeframe, to, last, current, period)

		SCHEDULER.every "#{period}", :first_in => 0 do |job|
			LOG.info "creating scheduler for #{title} query, #{statname}"

			case title

			when 'successful_1h'
				current = Job.new.current_points("#{statname}", "#{timeframe}", "#{to}", "http://graphite.prod.aws.justgiving.service/")
	            last  = Job.new.last_points("#{statname}", "#{timeframe}", "#{to}", "http://graphite.prod.aws.justgiving.service/")
	        when 'unsuccessful_1h'
				current = Job.new.current_points("#{statname}", "#{timeframe}", "#{to}", "http://graphite.prod.aws.justgiving.service/")
	            last  = Job.new.last_points("#{statname}", "#{timeframe}", "#{to}", "http://graphite.prod.aws.justgiving.service/")
	        when 'successful_day'
				current = Job.new.current_points("#{statname}", "#{timeframe}", "#{to}", "http://graphite.prod.aws.justgiving.service/")
	            last  = Job.new.last_points("#{statname}", "#{timeframe}", "#{to}", "http://graphite.prod.aws.justgiving.service/")
	        when 'unsuccessful_day'
				current = Job.new.current_points("#{statname}", "#{timeframe}", "#{to}", "http://graphite.prod.aws.justgiving.service/")
	            last  = Job.new.last_points("#{statname}", "#{timeframe}", "#{to}", "http://graphite.prod.aws.justgiving.service/")
	        when 'invalid_3d_1h'
				current = Job.new.current_points("#{statname}", "#{timeframe}", "#{to}", "http://graphite.prod.aws.justgiving.service/")
	            last  = Job.new.last_points("#{statname}", "#{timeframe}", "#{to}", "http://graphite.prod.aws.justgiving.service/")
	        when 'invalid_3d_day'
				current = Job.new.current_points("#{statname}", "#{timeframe}", "#{to}", "http://graphite.prod.aws.justgiving.service/")
	            last  = Job.new.last_points("#{statname}", "#{timeframe}", "#{to}", "http://graphite.prod.aws.justgiving.service/")
	        when 'invalid_cc_1h'
				current = Job.new.current_points("#{statname}", "#{timeframe}", "#{to}", "http://graphite.prod.aws.justgiving.service/")
	            last  = Job.new.last_points("#{statname}", "#{timeframe}", "#{to}", "http://graphite.prod.aws.justgiving.service/")
					when 'nprt_30mins'
					current = Job.new.current_points("#{statname}", "#{timeframe}", "#{to}", "http://graphite.prod.aws.justgiving.service/")
		          last  = Job.new.last_points("#{statname}", "#{timeframe}", "#{to}", "http://graphite.prod.aws.justgiving.service/")
	        when 'invalid_cc_day'
				current = Job.new.current_points("#{statname}", "#{timeframe}", "#{to}", "http://graphite.prod.aws.justgiving.service/")
	            last  = Job.new.last_points("#{statname}", "#{timeframe}", "#{to}", "http://graphite.prod.aws.justgiving.service/")
	        when 'unauthorized_1h'
				current = Job.new.current_points("#{statname}", "#{timeframe}", "#{to}", "http://graphite.prod.aws.justgiving.service/")
	            last  = Job.new.last_points("#{statname}", "#{timeframe}", "#{to}", "http://graphite.prod.aws.justgiving.service/")
	        when 'unauthorized_day'
				current = Job.new.current_points("#{statname}", "#{timeframe}", "#{to}", "http://graphite.prod.aws.justgiving.service/")
	            last  = Job.new.last_points("#{statname}", "#{timeframe}", "#{to}", "http://graphite.prod.aws.justgiving.service/")
	        when 'worldpay_1h'
				current = Job.new.current_points("#{statname}", "#{timeframe}", "#{to}", "http://graphite.prod.aws.justgiving.service/")
	            last  = Job.new.last_points("#{statname}", "#{timeframe}", "#{to}", "http://graphite.prod.aws.justgiving.service/")
	        when 'worldpay_day'
				current = Job.new.current_points("#{statname}", "#{timeframe}", "#{to}", "http://graphite.prod.aws.justgiving.service/")
	            last  = Job.new.last_points("#{statname}", "#{timeframe}", "#{to}", "http://graphite.prod.aws.justgiving.service/")
	        when 'paypal_success_10min'
	            statname_lastweek = "#{statname}_lastweek"
	            current = Job.new.current_points("#{statname}", "#{timeframe}", "#{to}", "http://graphite.prod.aws.justgiving.service/")
	            last = Job.new.current_points("#{statname_lastweek}", "#{timeframe}", "#{to}", "http://graphite.prod.aws.justgiving.service/")
	            LOG.info "title: #{title}, polling period: #{period}, metric1: #{statname}, metric2: #{statname_lastweek}, time period: #{timeframe}, current value: #{current} and last value: #{last}"
	        when 'paypal_success_midnight'
	        	statname_lastweek = "#{statname}_lastweek"
	            current = Job.new.current_points("#{statname}", "#{timeframe}", "#{to}", "http://graphite.prod.aws.justgiving.service/")
	            last = Job.new.current_points("#{statname_lastweek}", "#{timeframe}", "#{to}", "http://graphite.prod.aws.justgiving.service/")
	            LOG.info "title: #{title}, polling period: #{period}, metric1: #{statname}, metric2: #{statname_lastweek}, time period: #{timeframe}, current value: #{current} and last value: #{last}"

	        else
	          raise "Please specify metric"
	          exit

	        end

	        LOG.info "title: #{title}, metric: #{statname}, time period: #{timeframe}, current value: #{current} and last value: #{last}"

	        begin
			    send_event("#{title}", { last: last, current: current})
			rescue Exception => err
        	    LOG.info " ***Data sending failure for #{title} #{Time.now} err=#{err}"
                LOG.info " ***Data sending failure for #{title} #{Time.now} err=#{err.backtrace.join("\n")}"
			end

		end

end


start_scheduler('successful_1h', 'stats.counters.donations.events.donations.successful.count', "-1hour", "-1d", 0, 0, '1m')
start_scheduler('unsuccessful_1h', 'stats.counters.donations.events.donations.unsuccessful.count', "-1hour", "-1d", 0, 0, '1m')
start_scheduler('successful_day', 'stats.counters.donations.events.donations.successful.count', "midnight", "-1d", 0, 0, '1m')
start_scheduler('unsuccessful_day', 'stats.counters.donations.events.donations.unsuccessful.count', "midnight", "-1d", 0, 0, '1m')
start_scheduler('invalid_3d_1h', 'stats.counters.donations.events.donations.byResultCodeName.Invalid3DSecureData.count', "-1hour", "-1d", 0, 0, '1m')
start_scheduler('invalid_3d_day', 'stats.counters.donations.events.donations.byResultCodeName.Invalid3DSecureData.count', "midnight", "-1d", 0, 0, '1m')
start_scheduler('invalid_cc_1h', 'stats.counters.donations.events.donations.byResultCodeName.Invalidcreditcardnumber.count', "-1hour", "-1d", 0, 0, '1m')
start_scheduler('nprt_30mins', 'applications.donations.nprt.lasthalfhour', "-1minutes", "-1d", 0, 0, '1m')
start_scheduler('invalid_cc_day', 'stats.counters.donations.events.donations.byResultCodeName.Invalidcreditcardnumber.count', "midnight", "-1d", 0, 0, '1m')
start_scheduler('unauthorized_1h', 'stats.counters.donations.events.donations.byResultCodeName.TransactionNotAuthorized.count', "-1hour", "-1d", 0, 0, '1m')
start_scheduler('unauthorized_day', 'stats.counters.donations.events.donations.byResultCodeName.TransactionNotAuthorized.count', "midnight", "-1d", 0, 0, '1m')
start_scheduler('worldpay_1h', 'sumSeries(stats.counters.jg.payments.paymentagent.donations.IP-*.worldpay.failure.count)', "-1hour", "-1d", 0, 0, '1m')
start_scheduler('worldpay_day', 'sumSeries(stats.counters.jg.payments.paymentagent.donations.IP-*.worldpay.failure.count)', "midnight", "-1d", 0, 0, '1m')
start_scheduler('paypal_success_10min', 'applications.donations.paypal.lastmin', "-1minutes", "-7d", 0, 0, '1m')
start_scheduler('paypal_success_midnight', 'applications.donations.paypal.since_midnight', "-1minutes", "-7d", 0, 0, '1m')
