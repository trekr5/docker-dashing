require 'open-uri'
require 'json'
require 'dashing'
require 'elasticsearch'
require 'date'
require 'time'

# require '/home/graphite/lib/lasthour'
require '/graphite/lib/elastic1'
require '/graphite/lib/elastic2'
require '/graphite/lib/elastic3'
require '/graphite/lib/elastic4'
require '/graphite/lib/elastic5'
require '/graphite/lib/elastic6'

#URL = "http://graphite.prod.aws.justgiving.service/"
#INTERVAL = '1m'
LOG_FILE = '/graphite/dashing.log'
# class Logger
# 	#LOG_FILE = '/home/graphite/dashing.log'

# 	def self.log(msg)
# 		puts(msg)
# 		File.open(LOG_FILE, "a+") {|f| f.puts msg}
# 	end
# end
# job_mapping_1 = {
# 	'target_404_1min' => 'stats.counters.donations.events.donations.successful.count',#data_id
#     'target_405_1min' => 'stats.counters.donations.events.donations.unsuccessful.count'
#     # 'target_406_1min' => 'stats.counters.donations.events.donations.count.count'
# }

 File.open(LOG_FILE, "a+"){ |f| f.puts "initial boot at #{Time.now}..." }

 class Job
 		# include GraphiteQuery
 		include ElasticQuery1
 		include ElasticQuery2
 		include ElasticQuery3
 		include ElasticQuery4
 		include ElasticQuery5
 		include ElasticQuery6
 end

 	    def start_scheduler(type_of_query, title, statname, poll_period, timeframe, to, last, current, url, random)
 	    	 
 	  #  File.open(LOG_FILE, "a+"){ |f| f.puts "beginning: #{type_of_query} random number: #{random}" }
 	    
 	    	# job_mapping_1.each do |title, statname|
 	    	#options.each do |title, statname|
	 	   SCHEDULER.every "#{poll_period}", :first_in => 0 do |job|

	       File.open(LOG_FILE, "a+"){ |f| f.puts "creating scheduler for #{type_of_query} query, #{title} and started with a #{poll_period} polling period..."} 

				         case type_of_query
	                   #  	when "query_graphite"
	             	 	 		# current = Job.new.current_points("#{statname}", "#{timeframe}", "#{to}", "#{url}")
	             	 	 		# last  = Job.new.last_points("#{statname}", "#{timeframe}", "#{to}", "#{url}")
                    #            File.open(LOG_FILE, "a+"){|f| f.puts "current: #{current}, last: #{last}"}
	             	 	 	when "query_elastic_1"
	             	 	 	   current, last = Job.new.elastic_query_1("#{statname}", "#{timeframe}", "#{title}", "#{last}", "#{current}")
	             	 	 	 when "query_elastic_2"
	             	 	 	    current, last = Job.new.elastic_query_2("#{statname}", "#{timeframe}", "#{title}", "#{last}", "#{current}")
	             	 	 	 when "query_elastic_3"
	             	 	 	    current, last = Job.new.elastic_query_3("#{statname}", "#{timeframe}", "#{title}", "#{last}", "#{current}")
	             	 	 	when "query_elastic_4"
	             	 	 	   current, last = Job.new.elastic_query_4("#{statname}", "#{timeframe}", "#{title}", "#{last}", "#{current}")    
	             	 	 	when "query_elastic_5"
	             	 	 	    current, last = Job.new.elastic_query_5("#{statname}", "#{timeframe}", "#{title}", "#{last}", "#{current}")      
	             	 	 	when "query_elastic_6"
	             	 	 	    current, last = Job.new.elastic_query_6("#{statname}", "#{timeframe}", "#{title}", "#{last}", "#{current}")          
                  	        else
	             	 	 	    raise "Please specify type of query..."
	             	 	 	    exit
	             	 	end 
	             	# 	File.open(LOG_FILE, "a+"){ |f| f.puts "end: #{type_of_query} random number: #{random}"}
	            File.open(LOG_FILE, "a+"){ |f| f.puts "" } 		       	
			    File.open(LOG_FILE, "a+"){ |f| f.puts "query: #{type_of_query}, title: #{title}, metric: #{statname}, period: #{timeframe}, current value: #{current} and previous 24h value: #{last}" }
			    File.open(LOG_FILE, "a+"){ |f| f.puts "" } 

				                stat_metric = ["dev.redis.logstash", "staging.redis.logstash", "prod.redis.logstash"]
		         					if stat_metric.include?("#{statname}") && current == 0.0
				                  
														  current = last
								  	else
														  current

								  	end
													
				        begin		
			        		send_event("#{title}", { last: last, current: current})
				        rescue Exception => err
        	                 File.open(LOG_FILE, "a+"){ |f| f.puts " ***Data sending failure for #{title} #{Time.now} err=#{err}" }
-                            File.open(LOG_FILE, "a+"){ |f| f.puts " ***Data sending failure for #{title} #{Time.now} err=#{err.backtrace.join("\n")}"}
						end
	          end
	        #end
	    end  
#end..

r = Random.new

# start_scheduler("query_graphite",'active_no_of_users', 'googleAnalyticsRealTime.activeUsers', '1m', "-1minute", "-1minute", 0, 0,"http://graphite.prod.aws.justgiving.service/", r.rand(10...420))
# start_scheduler("query_graphite",'successful_1h', 'stats.counters.donations.events.donations.successful.count', '1m', "-1hour", "-1d", 0, 0,"http://graphite.prod.aws.justgiving.service/", r.rand(10...420))
# start_scheduler("query_graphite",'unsuccessful_1h', 'stats.counters.donations.events.donations.unsuccessful.count', '1m', "-1hour", "-1d", 0, 0,"http://graphite.prod.aws.justgiving.service/", r.rand(10...420))
# start_scheduler("query_graphite",'successful_day', 'stats.counters.donations.events.donations.successful.count', '1m', "midnight", "-1d", 0, 0,"http://graphite.prod.aws.justgiving.service/", r.rand(10...420))
# start_scheduler("query_graphite",'unsuccessful_day', 'stats.counters.donations.events.donations.unsuccessful.count', '1m', "midnight", "-1d", 0, 0,"http://graphite.prod.aws.justgiving.service/", r.rand(10...420))
# start_scheduler("query_graphite",'invalid_3d_1h', 'stats.counters.donations.events.donations.byResultCodeName.Invalid3DSecureData.count', '1m', "-1hour", "-1d", 0, 0,"http://graphite.prod.aws.justgiving.service/", r.rand(10...420))
# start_scheduler("query_graphite",'invalid_3d_day', 'stats.counters.donations.events.donations.byResultCodeName.Invalid3DSecureData.count', '1m', "midnight", "-1d", 0, 0,"http://graphite.prod.aws.justgiving.service/", r.rand(10...420))
# start_scheduler("query_graphite",'invalid_cc_1h', 'stats.counters.donations.events.donations.byResultCodeName.Invalidcreditcardnumber.count', '1m', "-1hour", "-1d", 0, 0,"http://graphite.prod.aws.justgiving.service/", r.rand(10...420))
# start_scheduler("query_graphite",'invalid_cc_day', 'stats.counters.donations.events.donations.byResultCodeName.Invalidcreditcardnumber.count', '1m', "midnight", "-1d", 0, 0,"http://graphite.prod.aws.justgiving.service/", r.rand(10...420))
# start_scheduler("query_graphite",'unauthorized_1h', 'stats.counters.donations.events.donations.byResultCodeName.TransactionNotAuthorized.count', '1m', "-1hour", "-1d", 0, 0,"http://graphite.prod.aws.justgiving.service/", r.rand(10...420))
# start_scheduler("query_graphite",'unauthorized_day', 'stats.counters.donations.events.donations.byResultCodeName.TransactionNotAuthorized.count', '1m', "midnight", "-1d", 0, 0,"http://graphite.prod.aws.justgiving.service/", r.rand(10...420))
# start_scheduler("query_graphite",'worldpay_1h', 'sumSeries(stats.counters.jg.payments.paymentagent.donations.IP-*.worldpay.failure.count)', '1m', "-1hour", "-1d", 0, 0,"http://graphite.prod.aws.justgiving.service/", r.rand(10...420))
# start_scheduler("query_graphite",'worldpay_day', 'sumSeries(stats.counters.jg.payments.paymentagent.donations.IP-*.worldpay.failure.count)', '1m', "midnight", "-1d", 0, 0,"http://graphite.prod.aws.justgiving.service/", r.rand(10...420))
# start_scheduler("query_graphite", 'dev_redis_logstash', 'dev.redis.logstash', '1m', "-1minute", "-1minute", 0, 0,"http://graphite.dev.aws.justgiving.service/", r.rand(10...420)) 
# start_scheduler("query_graphite", 'staging_redis_logstash', 'staging.redis.logstash', '1m', "-1minute", "-1minute", 0, 0,"http://graphite.staging.aws.justgiving.service/", r.rand(10...420))
# start_scheduler("query_graphite", 'prod_redis_logstash', 'prod.redis.logstash', '1m', "-1minute", "-1minute", 0, 0, "http://graphite.prod.aws.justgiving.service/", r.rand(10...420))
start_scheduler("query_elastic_1", 'failed_1h', "response", '1m', "now-1h", 0, 0, 0, "", r.rand(10...420))
start_scheduler("query_elastic_1", 'failed_day', "response", '1m', "now/d", 0, 0, 0,"", r.rand(10...420))
start_scheduler("query_elastic_2", 'awesome_1h', "referrer", '1m', "now-1h", 0, 0, 0,"", r.rand(10...420))
start_scheduler("query_elastic_2", 'awesome_day', "referrer", '1m', "now/d", 0, 0, 0,"", r.rand(10...420))
start_scheduler("query_elastic_3", 'sms_1h', "request", '1m', "now-1h", 0, 0, 0,"", r.rand(10...420))
start_scheduler("query_elastic_3", 'sms_day', "request", '1m', "now/d", 0, 0, 0,"", r.rand(10...420))
start_scheduler("query_elastic_4", 'classic_1h', "request", '1m', "now-1h", 0, 0, 0,"", r.rand(10...420))
start_scheduler("query_elastic_4", 'classic_day', "request", '1m', "now/d", 0, 0, 0,"", r.rand(10...420))
start_scheduler("query_elastic_5", 'paypal_1h', "request", '1m', "now-1h", 0, 0, 0,"", r.rand(10...420))
start_scheduler("query_elastic_5", 'paypal_day', "request", '1m', "now/d", 0, 0, 0,"", r.rand(10...420))
start_scheduler("query_elastic_6", 'paypal_failed_1h', "response", '1m', "now-1h", 0, 0, 0,"", r.rand(10...420))
start_scheduler("query_elastic_6", 'paypal_failed_day', "response", '1m', "now/d", 0, 0, 0,"", r.rand(10...420))
