
module ElasticQuery1

  #File.open(LOG_FILE, "a+"){ |f| f.puts "inside elastic query 1..." }

	def start_elastic

		   index_output = %x(curl -XGET "http://esearch.logs.prod.aws.justgiving.service:80/_stats/indices?pretty=true" )
	     index_output_hash = JSON.parse(index_output)
	     indices = index_output_hash["indices"]
	     logstash_dates = indices.collect {|k, v| k}.sort.grep(/logstash/)
	     current_logstash_date = logstash_dates[-1]
       previous_logstash_date = logstash_dates[-2]
      # previous24h_logstash_date = logstash_dates[-3]

    File.open(LOG_FILE, "a+"){ |f| f.puts "current index is: #{current_logstash_date} loaded successfully" }
	     return current_logstash_date, previous_logstash_date
  end 

  def prev_date_and_current_time
  
      time_now = Time.now
      prev_hour = time_now.hour - 1
      prev_day = Date.today.prev_day
      prev_prev_day = prev_day.prev_day

      return time_now, prev_day, prev_hour, prev_prev_day

  end 

  def now(elastic_values)
       current = elastic_values[1]
       last = elastic_values[3]
       return current, last
  end  

  def midnight(elastic_values)
       current = elastic_values[5]
       last = elastic_values[7]
       return current, last

  end

  def elastic_query_1(statname, timeframe, title, last, current)

        current_logstash_date, previous_logstash_date = start_elastic
        time_now, prev_day, prev_hour, prev_prev_day = prev_date_and_current_time

        client = Elasticsearch::Client.new hosts: [{host: 'view.logs.prod.aws.justgiving.service', port: 80 ,user: 'showme', password: 'thel0gs'}], request_timeout: 2*60 
            #client = Elasticsearch::Client.new hosts: [{host: '10.50.14.120', port: 9200}]

        File.open(LOG_FILE, "a+"){ |f| f.puts "Client #{client} loaded successfully" }

      hash_midnight_now =   {
           "query"=> {
               "filtered"=> {
                   "filter"=> {
                       "bool"=> {
                           "must"=> [
                               {"term"=> {"fleet"=> "waf"}},
                               {"term"=> {"#{statname}"=> 500}},
                               {"term"=> {"request"=> "oops"}},
                               "range"=> {
                                   "@timestamp"=> {
                                       "gt"=> "#{timeframe}"
                                   }
                               },
                               "should"=> [
                                 #  {"term"=> {"queryparam"=> "Paypal"}},
                                   {"term"=> {"request"=> "donation"}},
                               ],
                               "must_not"=> {"term"=> {"useragent"=> "Googlebot2.1"}},
                             "must_not"=> {"term"=> {"useragent"=> "Facebookbot"}},
                           ]
                       }
                   }
               }
           },
           "aggs"=> {
               "0"=> {
                   "date_histogram"=> {
                       "field"=> "@timestamp",
                       #"pre_zone_adjust_large_interval"=> "24h"
                       "interval"=> "1h"
                   }
               }
           },
           "size"=> 0
       }
 

       hash_midnight_last =      {

                "query"=> {
                    "filtered"=> {
                        "filter"=> {
                            "bool"=> {
                                "must"=> [
                                    {"term"=> {"fleet"=> "waf"}},
                                    {"term"=> {"#{statname}"=> 500}},
                                    {"term"=> {"request"=> "oops"}},
                                    "range"=> {
                                        "@timestamp"=> {
                                            "gt"=> "#{prev_day.year}-#{prev_day.mon}-#{prev_day.day}T00:00:00",
                                            "lt"=> "#{prev_day.year}-#{prev_day.mon}-#{prev_day.day}T#{prev_hour}:#{time_now.min}:00"

                                        }
                                    },
                                    "should"=> [
                                     #     {"term"=> {"queryparam"=> "Paypal"}},
                                        {"term"=> {"request"=> "donation"}},
                                    ],
                                    "must_not"=> {"term"=> {"useragent"=> "Googlebot2.1"}},
                                   "must_not"=> {"term"=> {"useragent"=> "Facebookbot"}},
                                ]
                            }
                        }
                    }
                },
                "aggs"=> {
                    "0"=> {
                        "date_histogram"=> {
                            "field"=> "@timestamp",
                            #"pre_zone_adjust_large_interval"=> "24h"
                            "interval"=> "1h"
                        }
                    }
                },
                "size"=> 0
            }
        

      hash_last =  {

                "query"=> {
                    "filtered"=> {
                        "filter"=> {
                            "bool"=> {
                                "must"=> [
                                    {"term"=> {"fleet"=> "waf"}},
                                    {"term"=> {"#{statname}"=> 500}},
                                    {"term"=> {"request"=> "oops"}},
                                    "range"=> {
                                        "@timestamp"=> {
                                            "gt"=> "now-25h",
                                            "lt"=> "now-24h"
                                        }
                                    },
                                    "should"=> [
                                        #   {"term"=> {"queryparam"=> "Paypal"}},
                                        {"term"=> {"request"=> "donation"}},
                                    ],
                                    "must_not"=> {"term"=> {"useragent"=> "Googlebot2.1"}},
                                    "must_not"=> {"term"=> {"useragent"=> "Facebookbot"}},
                                ]
                            }
                        }
                    }
                },
                "aggs"=> {
                    "0"=> {
                        "date_histogram"=> {
                            "field"=> "@timestamp",
                            #"pre_zone_adjust_large_interval"=> "24h"
                            "interval"=> "1h"
                        }
                    }
                },
                "size"=> 0
            }
            
       hash_current =  
       {
           "query"=> {
               "filtered"=> {
                   "filter"=> {
                       "bool"=> {
                           "must"=> [
                               {"term"=> {"fleet"=> "waf"}},
                               {"term"=> {"#{statname}"=> 500}},
                               {"term"=> {"request"=> "oops"}},
                               "range"=> {
                                   "@timestamp"=> {
                                       "gt"=> "#{timeframe}"
                                   }
                               },
                               "should"=> [
                                   #  {"term"=> {"queryparam"=> "Paypal"}},
                                   {"term"=> {"request"=> "donation"}},
                               ],
                               "must_not"=> {"term"=> {"useragent"=> "Googlebot2.1"}},
                               "must_not"=> {"term"=> {"useragent"=> "Facebookbot"}},
                           ]
                       }
                   }
               }
           },
           "aggs"=> {
               "0"=> {
                   "date_histogram"=> {
                       "field"=> "@timestamp",
                       #"pre_zone_adjust_large_interval"=> "24h"
                       "interval"=> "1h"
                   }
               }
           },
           "size"=> 0
       }

       begin
    value_current = client.search index: current_logstash_date, body: hash_current
    value_current_midnight = client.search index: current_logstash_date, body: hash_midnight_now
       rescue Exception => err
         File.open(LOG_FILE, "a+"){ |f| f.puts " title: #{title}, value_current_failed query failure #{Time.now} err=#{err}"}
         File.open(LOG_FILE, "a+"){ |f| f.puts " title: #{title}, value_current_failed query failure #{Time.now} err=#{err.backtrace.join("\n")}"}
       end  

     begin
   #   File.open(LOG_FILE, "a+"){ |f| f.puts " hash last: #{hash_last}"}
    value_last = client.search index: [current_logstash_date, previous_logstash_date], body: hash_last
    value_last_midnight = client.search index: [current_logstash_date, previous_logstash_date], body: hash_midnight_last   

    rescue Exception => err
    File.open(LOG_FILE, "a+"){ |f| f.puts " title: #{title}, value_last_failed query failure #{Time.now} err=#{err}"}
    File.open(LOG_FILE, "a+"){ |f| f.puts " title: #{title}, value_last_failed query failure #{Time.now} err=#{err.backtrace.join("\n")}"}
    end

  values = []
  values <<  {time: timeframe, value: value_current["hits"]["total"]}
  values <<  {time: timeframe, value: value_last["hits"]["total"]}
  values <<  {time: timeframe, value: value_current_midnight["hits"]["total"]}
  values <<  {time: timeframe, value: value_last_midnight["hits"]["total"]}

        File.open(LOG_FILE, "a+"){ |f| f.puts "Values #{values} for #{title}..\n" }

  elastic_values = values.map(&:values).flatten
  elastic_values.each_with_index do |element, index|

  if elastic_values[0] == "now-1h"
      current, last = now(elastic_values) 
  else  
      current, last = midnight(elastic_values)
  end  
#File.open(LOG_FILE, "a+"){ |f| f.puts "#{Time.now} last value: #{last},           \tdata id: #{title},           \tcurrent value: #{current}\n" }
end
  return current, last

  end

end
