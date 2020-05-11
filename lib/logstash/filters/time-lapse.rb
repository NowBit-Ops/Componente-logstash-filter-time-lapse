# encoding: utf-8
require "logstash/filters/base"
require "logstash/namespace"
# This example filter will replace the contents of the default
# message field with whatever you specify in the configuration.
#
# It is only intended to be used as an example.


class LogStash::Filters::TimeLapse < LogStash::Filters::Base

  # Setting the config_name here is required. This is how you
  # configure this filter from your Logstash config.
  #
  # filter {
  #   example {
  #     message => "My message..."
  #   }
  # }
  #
  config_name "time-lapse"

  # Replace the message with this value.
  config :transactionid, :validate => :string, :required => true
  config :datefield, :validate => :string, :default => "@timestamp"
  config :validationField, :validate => :string
  config :limitTime, :validate => :number, :default => 10

  def cleanHash()
    while true
      $hash.dup.each_key do |key|
        d = Time.now
        if (d.to_f - $hash[key][0].to_f > limitTime )
          $hash.delete(key)
        end
      end
      sleep limitTime
   end
  end

  public
  def register
    # Add instance variables
  $init = false
  $hash = {}
  x = Thread.new{cleanHash()} 
  end # def register

  public
  def filter(event)
    #unless @transactionid.nil? && @transactionid.empty? && @transactionid.length < 3
    #if @transactionid != nil && @transactionid != "" && @transactionid.length > 3

    unless event.get(@transactionid).nil?
      unless event.get(@transactionid).empty?
        if $hash[event.get(@transactionid)] == nil
          $hash[event.get(@transactionid)] = [event.get(@datefield)]
          event.set("duracion", 0)
        else
          hash = $hash[event.get(@transactionid)]
          firstDate = hash[0]

          $hash[event.get(@transactionid)] = [event.get(@datefield)]
          event.set('duracion',  event.get('@timestamp') - firstDate)

          # if firstService == event.get(@validationField)
          #   $hash.delete(@transactionid)
          # end
        end
      end
    end
    event.set("hash.size", $hash.size())

    # filter_matched should go in the last line of our successful code
    filter_matched(event)
  end # def filter
end # class LogStash::Filters::TimeLapse
