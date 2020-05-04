# encoding: utf-8
require "logstash/filters/base"
require "logstash/namespace"
require_relative "class_rbtree"
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

  public
  def register
    # Add instance variables
	$hash = {}

  end # def register

  public
  def filter(event)

    if @transactionid
  		if $hash[event.get(@transactionid)] == nil
  			$hash[event.get(@transactionid)] = [event.get(@datefield), event.get(@validationField)]
  			event.set("duracion", 0)
      else
        hash = $hash[event.get(@transactionid)]
        firstDate = hash[0]
        firstService = hash[1]

        
        $hash[event.get(@transactionid)] = [event.get(@datefield), firstService]
        event.set('duracion',  event.get('@timestamp') - firstDate)
        event.set('ServiceName',  firstService)

        if firstService == event.get(@validationField)
          $hash.delete(@transactionid)
        end
  		end
    end
    event.set("hash.size", $hash.size())

    # filter_matched should go in the last line of our successful code
    filter_matched(event)
  end # def filter
end # class LogStash::Filters::TimeLapse
