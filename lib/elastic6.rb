module ElasticQuery6

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

     def elastic_query_6(statname, timeframe, title, last, current)

              current_logstash_date, previous_logstash_date = start_elastic
              time_now, prev_day, prev_hour, prev_prev_day = prev_date_and_current_time

                client = Elasticsearch::Client.new hosts: [{host: 'view.logs.prod.aws.justgiving.service', port: 80 ,user: 'showme', password: 'thel0gs'}], request_timeout: 2*60 
         # client = Elasticsearch::Client.new hosts: [{host: '10.50.14.120', port: 9200}]

                File.open(LOG_FILE, "a+"){ |f| f.puts "Client #{client} loaded successfully..." }

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
                             {"term"=> {"request"=> "paypal"}},
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
                               {"term"=> {"request"=> "paypal"}},
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
                               {"term"=> {"request"=> "paypal"}},
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
                              {"term"=> {"request"=> "paypal"}},
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
File.open(LOG_FILE, "a+"){ |f| f.puts " title: #{title}, value_current_classic query failure #{Time.now} err=#{err}"}
File.open(LOG_FILE, "a+"){ |f| f.puts " title: #{title}, value_current_classic query failure #{Time.now} err=#{err.backtrace.join("\n")}"}
      end  

     begin
    value_last = client.search index: [current_logstash_date, previous_logstash_date], body: hash_last
    value_last_midnight = client.search index: [current_logstash_date, previous_logstash_date], body: hash_midnight_last  

    rescue Exception => err
File.open(LOG_FILE, "a+"){ |f| f.puts " title: #{title}, value_last_classic query failure #{Time.now} err=#{err}"}
File.open(LOG_FILE, "a+"){ |f| f.puts " title: #{title}, value_last_classic query failure #{Time.now} err=#{err.backtrace.join("\n")}"}
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

    end
        return current, last

  end


end