require 'json'
require 'logger'
require 'net/http'
require 'dashing'

LOGGER = Logger.new('/graphite/list.log')

def get_data(url)

    #output = %x(curl -ss "#{url}")
    uri = URI(url)
    # uri = URI("#{url}")
    output = Net::HTTP.get(uri)
    output_hash = JSON.parse(output)
    return output_hash
end 

def dataset(size, names, values)

    new_values = Hash.new
        new_names = names[0..size-1]
         count = 0
         while count <= size-1
            values.each do |k, v|

            # if count = size
            #     new_values[k] = v 
            #     count += 1
            # end
              new_values[k] = v
            end    
            count += 1
         end 

    return new_names, new_values
end   

def reformat_data(title="fundraising", items)

    items.each do |item|
        item[:label].gsub!(/(GET|HTTP\/1\.1|HTTP\/1\.0)/, "")
    end
    LOGGER.info "#{title}: \nitems: #{items}"

    return items            
end 

def structure_data(url)

    names = []
    values = Hash.new
    # new_values = Hash.new
    data = get_data(url)
     data["aggregations"]["2"]["buckets"].each do |source|
        names << source["key"]
        values[source["key"]] = source["doc_count"]

     end

     new_names, new_values = dataset(20, names, values)
     return new_names, new_values

end 

def start_scheduler(title, url)

        SCHEDULER.every '30s', :first_in => 0 do |job|
            names, values = structure_data(url)

            items = []

              LOGGER.info "#{title}: names: #{names} values: #{values}"

                       names.each do |name|
                              value = values[name]
                              items << {label: name, value: value}

                              if title == "fundraising"
                                items = reformat_data(title, items)
                              end  
                                # p "#{title}: \nitems: #{items}"
                                LOGGER.info "#{title}: \nitems: #{items}"
                       end 
                            
                    begin       
                        send_event("#{title}", { items: items})
                    rescue Exception => err
                        LOGGER.info " ***Data sending failure for #{title} #{Time.now} err=#{err}" 
                        LOGGER.info " ***Data sending failure for #{title} #{Time.now} err=#{err.backtrace.join("\n")}"
                    end
        end

end 

start_scheduler("fundraising", "http://waf.prod.justgiving.com/ops_stats/trending_fundraising.json")
start_scheduler("crowdfunding","http://waf.prod.justgiving.com/ops_stats/trending_crowdfunding.json")
