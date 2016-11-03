
require 'json'
require 'elasticsearch'
require 'dashing'
require 'date'
require 'time'
require 'logger'
require 'net/http'

LOG_GER = Logger.new('/graphite/errors.log')

class StatusErrors

        def connect_elastic

            uri = URI("http://esearch.logs.prod.aws.justgiving.service:80/_stats/indices?pretty=true")
            index_output = Net::HTTP.get(uri)

                # index_output = %x(curl -ss "http://esearch.logs.prod.aws.justgiving.service:80/_stats/indices?pretty=true" )
            index_output_hash = JSON.parse(index_output)
            indices = index_output_hash["indices"]
            logstash_dates = indices.collect {|k, v| k}.sort.grep(/logstash/)
            current_logstash_date = logstash_dates[-1]
            previous_logstash_date = logstash_dates[-2]
            LOG_GER.info "current index is #{current_logstash_date}, previous index is #{previous_logstash_date}"
            return current_logstash_date, previous_logstash_date

        end

        def elastic_client

           client = Elasticsearch::Client.new hosts: [{host: 'view.logs.prod.aws.justgiving.service', port: 80 ,user: 'showme', password: 'thel0gs'}], request_timeout: 2*60

           return client

        end

        def hash_query(statname, value, timeframe)

                  hash_last =  {
                 "query"=> {
                    "filtered"=> {
                        "filter"=> {
                            "bool"=> {
                                "must"=> [
                                    {"term"=> {"fleet"=> "waf"}},
                                    {"term"=> {"#{statname}"=> "#{value}"}},
                                    "range"=> {
                                        "@timestamp"=> {
                                            "gt"=> "now-25h",
                                            "lt"=> "now-24h"
                                        }
                                    },
                                ]
                            }
                        }
                    }
                },
                "aggs"=> {
                    "0"=> {
                        "date_histogram"=> {
                            "field"=> "@timestamp",
                            "interval"=> "1h"
                        }
                    }
                },
                "size"=> 0
            }

          hash_current =  {

           "query"=> {
               "filtered"=> {
                   "filter"=> {
                       "bool"=> {
                           "must"=> [
                               {"term"=> {"fleet"=> "waf"}},
                               {"term"=> {"#{statname}"=> "#{value}"}},
                               "range"=> {
                                   "@timestamp"=> {
                                       "gt"=> "#{timeframe}"
                                   }
                               },
                           ]
                       }
                   }
               }
           },
           "aggs"=> {
               "0"=> {
                   "date_histogram"=> {
                       "field"=> "@timestamp",
                       "interval"=> "1h"
                   }
               }
           },
           "size"=> 0
       }

          return hash_last, hash_current

       end

       def structure_values(data_id, timeframe, value_current, value_last, last, current)

                 values = []
                 values <<  {time: timeframe, value: value_current["hits"]["total"]}
                 values <<  {time: timeframe, value: value_last["hits"]["total"]}
                 LOG_GER.info "data_id: #{data_id}, \nvalues: #{values}"

                 #elastic_values = values.map(&:values).flatten
                 elastic_values = values.flat_map(&:values)
                 # elastic_values.each_with_index do |element, index|
                 current = elastic_values[1]
                 last = elastic_values[3]
                 # end
                 LOG_GER.info "current: #{current}, last: #{last}"

                 return current, last

        end

        def get_values(statname, value, timeframe, data_id, last, current)

            value_current = 0
            value_last = 0

            current_logstash_date, previous_logstash_date = connect_elastic
            client = elastic_client
            hash_last, hash_current = hash_query(statname, value, timeframe)
            value_current = client.search index: current_logstash_date, body: hash_current
            value_last = client.search index: [current_logstash_date, previous_logstash_date], body: hash_last

            LOG_GER.info "value_current is #{value_current}, value_last is #{value_last}"
            current, last = structure_values(data_id, timeframe, value_current, value_last, last, current)
            LOG_GER.info "data_id: #{data_id}, current is #{current}, last is #{last}"
            return data_id, current, last
                # p "data_id: #{data_id}, current: #{current}, last: #{last}"

        end
end   

def start_scheduler(input)

    SCHEDULER.every '1m', :first_in => 0 do |job|

        # last = current
        data_id, current, last = StatusErrors.new.get_values(input["statname"], input["value"], input["timeframe"], input["data_id"], input["last"], input["current"])
        LOG_GER.info "inside start scheduler: \ndata_id: #{data_id}, current is #{current}, last is #{last}"

        begin       
            send_event("#{data_id}", { current: current, last: last })

        rescue Exception => err
            LOG_GER.info " ***Data sending failure for #{input["data_id"]} #{Time.now} err=#{err}" 
            LOG_GER.info " ***Data sending failure for #{input["data_id"]} #{Time.now} err=#{err.backtrace.join("\n")}"
        end

        last = current

    end

end       

    input_data = [
                            [
                              {"statname" => "response", "value" => 500, "timeframe" => "now-1h", "data_id" => "error_500", "last" => 0, "current" => 0}
                            ],
                            [
                              {"statname" => "response", "value" => 501, "timeframe" => "now-1h", "data_id" => "error_501", "last" => 0, "current" => 0}
                            ],
                            [
                              {"statname" => "response", "value" => 502, "timeframe" => "now-1h", "data_id" => "error_502", "last" => 0, "current" => 0}
                            ],
                            [
                              {"statname" => "response", "value" => 503, "timeframe" => "now-1h", "data_id" => "error_503", "last" => 0, "current" => 0}
                            ],
                            [
                              {"statname" => "response", "value" => 504, "timeframe" => "now-1h", "data_id" => "error_504", "last" => 0, "current" => 0}
                            ],
                            [
                              {"statname" => "response", "value" => 400, "timeframe" => "now-1h", "data_id" => "error_400", "last" => 0, "current" => 0}
                            ],
                            [
                              {"statname" => "response", "value" => 401, "timeframe" => "now-1h", "data_id" => "error_401", "last" => 0, "current" => 0}
                            ],
                            [
                              {"statname" => "response", "value" => 403, "timeframe" => "now-1h", "data_id" => "error_403", "last" => 0, "current" => 0}
                            ],
                            [
                              {"statname" => "response", "value" => 404, "timeframe" => "now-1h", "data_id" => "error_404", "last" => 0, "current" => 0}
                            ]

                ]

    input_data.each do |data|
        data.each do |stat|
           # get_values(i["statname"], i["value"], i["timeframe"], i["data_id"], i["last"], i["current"])
           start_scheduler(stat)

        end
    end

    
