# encoding: utf-8
require "csv"
require "logstash/codecs/base"
require "logstash/util/charset"

# The "plain" codec is for plain text with no delimiting between events.
#
# This is mainly useful on inputs and outputs that already have a defined
# framing in their transport protocol (such as zeromq, rabbitmq, redis, etc)
class LogStash::Codecs::CSV2 < LogStash::Codecs::Base
  config_name "csv2"


  config :csv_options, :validate => :hash, :required => false, :default => Hash.new
  config :spreadsheet_safe, :validate => :boolean, :default => true
  config :fields, :validate => :array, :required => true

  public
  def register
    @csv_options = Hash[@csv_options.map{|(k, v)|[k.to_sym, v]}]
  end

  public
  #def decode(data)
  #  yield LogStash::Event.new("message" => @converter.convert(data))
  #end # def decode

  public
  def encode(event)
    csv_values = @fields.map {|name| get_value(name, event)}
    @on_event.call(event,csv_values.to_csv(@csv_options))
  end # def encode

  private
  def get_value(name, event)
    val = event.get(name)
    val.is_a?(Hash) ? LogStash::Json.dump(val) : escape_csv(val)
  end

  private
  def escape_csv(val)
    (spreadsheet_safe && val.is_a?(String) && val.start_with?("=")) ? "'#{val}" : val
  end
end # class LogStash::Codecs::Plain
