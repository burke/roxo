require 'active_support/inflector'
require 'libxml' 

# Ruby Objects as XML Objects
class ROXO
  (instance_methods - %w{__send__ __id__ object_id class send}).each{|m|eval "undef #{m}"}

  include Comparable
  
  attr_reader :raw, :name, :value, :children
  def   attributes; @attributes.keys;       end
  def      has?(o); !! send(o);             end # Boolean. Does this exist?
  def        [](o); @attributes[o.to_s];    end # Only lookup attributes
  def         to_s; @value;                 end 
  
  def __attributes
    @attributes.sort.reject{|a|a.to_s =~ /^xmlns/}
  end 

  def initialize(xml)
    xml = ::LibXML::XML::Parser.string(xml).parse.root unless xml.kind_of?(LibXML::XML::Node)

    @raw, @name, @attributes = xml, xml.name, xml.attributes.to_h
    @children = xml.children.select(&:element?).group_by{|c|c.name.to_sym}
    @value = xml.children.select{|e|e.text? or e.cdata?}.map{|e|e.to_s.chomp(']]>').sub('<![CDATA[','')}.join
  end

  def inspect
    terminal? ? value.inspect : "#<ROXO:0x#{object_id.to_s(16)} @name=\"#{@name}\", ...>"
  end 

  def terminal? 
    @children.blank? and @attributes.blank?
  end # A node is terminal if we can't descend any further

  def <=>(other)
    return -1 unless (self.class == other.class)
    return z unless (z = self.__attributes <=> other.__attributes).zero?
    return z unless (z = self.value <=> other.value).zero?
    return z unless (z = self.name <=> other.name).zero?

    nodes = lambda{|obj|obj.children.values.flatten.map{|n|self.class.new(n)}}
    nodes[self] <=> nodes[other]
  end

  def ==(o)
    self.<=>(o) == 0
  end 
  
  def method_missing(sym, *args)
    if terminal? # Proxy all method calls to the wrapped object.
      return @value.send(sym, *args)
    elsif sym.to_s[-1..-1]=="?" # re-dispatch without question mark, interpret result as a boolean.
      return %w{yes true t y}.include?(send(sym.to_s[0..-2].to_sym, *args).downcase)
    elsif @children[sym]
      x = self.class.new(@children[sym].first)
      return x.terminal? ? x.value : x
    elsif @attributes[sym.to_s]
      return @attributes[sym.to_s]
    elsif @children[sing = sym.to_s.singularize.to_sym]
      return @children[sing].map{|e|self.class.new(e)}
    end 
  end

end
