require 'active_support/inflector'
require 'libxml' 

# Ruby Objects as XML Objects
class ROXO
  instance_methods.each do |meth|
    eval "undef #{meth}" unless [:__send__, :__id__, :object_id, :class].include?(meth.to_sym)
  end

  include Comparable
  
  attr_reader :raw, :name, :value, :children
  def __attributes; @attributes.sort;       end
  def   attributes; @attributes.keys;       end
  def    terminal?; @children.size.zero?;   end # A node is terminal if we can't descend any further
  def      has?(o); !! send(o);             end # Boolean. Does this exist?
  def        [](o); @attributes[o.to_s];    end # Only lookup attributes
  def         to_s; @value;                 end 
  
  def initialize(xml)
    xml = ::LibXML::XML::Parser.string(xml).parse.root unless xml.kind_of?(LibXML::XML::Node)

    @raw, @name, @attributes = xml, xml.name, xml.attributes.to_h
    @children = xml.children.select(&:element?).group_by{|c|c.name.to_sym}

    text_value  = xml.children.select(&:text?).map(&:to_s).reject(&:empty?).join
    cdata_value = xml.children.select(&:cdata?).map{|c|c.to_s.chomp(']]>').sub('<![CDATA[', '')}.join
    @value = text_value.empty? ? cdata_value : text_value
  end

  def inspect
    terminal? ? value.inspect : "#<ROXO:0x#{object_id.to_s(16)} @name=\"#{@name}\", ...>"
  end 

  def <=>(other)
    [:class, :__attributes, :value, :name].each do |key|
      return z unless (z = self.send(key) <=> other.send(key)).zero?
    end 
    nodes = lambda{|obj|obj.children.values.flatten.map{|n|self.class.new(n)}}
    nodes[self] <=> nodes[other]
  end

  def method_missing(sym, *args)
    if @children[sym]
      return self.class.new(@children[sym].first)
    elsif @attributes[sym.to_s]
      return @attributes[sym.to_s]
    elsif @children[sing = sym.to_s.singularize.to_sym]
      return @children[sing].map{|e|self.class.new(e)}
    end 
  end

end
