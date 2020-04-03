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
  config_name "timelapse"

  # Replace the message with this value.
  config :transactionid, :validate => :string, :required => true
  config :datefield, :validate => :string, :default => "@timestamp"

  public
  def register
    # Add instance variables
	hash = Hash.new

  end # def register

  public
  def filter(event)

    if @transactionid
  		if hash[:event.get(@transactionid)] == nil
  			hash[:event.get(@transactionid)] = event.get(@datefield)
  			event.set("duracion", 0)
  		else
  			firstDate = hash[:event.get(@transactionid)]
  			event.set('duracion', LogStash::Timestamp.new(Time.strptime(firstDate, '%Y-%m-%d %H:%M:%S')) - event.get('@timestamp'))
  		end
    end

    # filter_matched should go in the last line of our successful code
    filter_matched(event)
  end # def filter
end # class LogStash::Filters::TimeLapse
