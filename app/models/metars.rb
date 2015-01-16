class Metars
  require 'open-uri'
  attr_reader :raw_text

  def initialize(station)
    @station = "KPNS"
    get_metars
  end

  protected

  def method_missing(method_name, *args, &block)
    if method_name.to_s =~ /avwx_(.*)/
      instance_variable_set "@#{$1}".downcase, args[0]
    else
      super
    end
  end

  def respond_to_missing?(method_name, include_private = false)
    method_name.to_s.start_with?('avx_') || super
  end

  private

  # MOVE TO CONCERN
  def wx_url(type)
    type.downcase!
    forecasts = ["metars", "tafs"]
    if forecasts.include?(type)
      url = "http://aviationweather.gov/adds/dataserver_current/httpparam?datasource=#{type}&requestType=retrieve&format=xml&mostRecentForEachStation=constraint&hoursBeforeNow=12&stationString=#{@stations}"
    else
      return "Invalid Forecast Type: #{type}"
    end
  end

  def get_xml_object(type)
    response = open(wx_url(type))
    Nokogiri::XML(response.read).xpath("//#{type[0...-1].upcase}")
  end

  def metar_to_obj(metars_noko_xml)
    metars_noko_xml.each do |metar|
      parse_metar_xml(metar)
    end
  end

  #KEEP IN METAR
  def parse_metar_xml(metar)
    # station = metar.css("station_id").text
    # metar_hash[station] = {}
    exclude_from_object = ["sky_condition", "quality_control_flags"]
    metar.children.each do |c|
      if !c.blank? && !exclude_from_object.include?(c.name)
        send "avwx_#{c.name}", c.content
        #metar_hash[station][c.name] = c.content
      elsif c.name == "sky_condition"
        send "avwx_#{c.name}", attribute_hash(c.attributes)
      #   metar_hash[station][c.name] = attribute_hash(c.attributes)
      elsif c.name == "quality_control_flags"
        send "avwx_#{c.name}", child_hash(c.children)
      #   metar_hash[station][c.name] = child_hash(c.children)
      end
    end
  end

  def attribute_hash(attributes)
    att_hash = {}
    attributes.each do |a, v|
      att_hash[a] = v.to_s
    end
    att_hash
  end

  def child_hash(children)
    child_hash = {}
    children.each do |c|
      child_hash[c.name] = c.content unless c.blank?
    end
    child_hash
  end

  def get_metars
    metars_xml = get_xml_object('metars')
    # metars_xml.each do |metar|
      parse_metar_xml(metars_xml.first)
    # end
    # metar_hash
  end
end