require 'rubygems'
require 'active_support/inflector'
require 'libxml' 

# z = ROXO.new("<foo a='zxcv'><bar><baz>asdf</baz></bar></foo>")
# z.a #=> "zxcv"
# z.bar.baz #=> "asdf"

# Ruby Objects as XML Objects
class ROXO
  instance_methods.each do |meth|
    eval "undef #{meth}" unless [:__send__, :__id__, :object_id, :class].include?(meth.to_sym)
  end

  include Comparable
  
  # Accessors and other one-liners
  attr_reader :raw, :name, :value, :children
  def __attributes; @attributes;            end
  def   attributes; @attributes.keys;       end
  def    terminal?; @children.size.zero?;   end # A node is terminal if we can't descend any further
  def      has?(o); !! send(o);             end # Boolean. Does this exist?
  def        [](o); @attributes[o.to_s];    end # Only lookup attributes
  def         to_s; @value;                 end 
  
  def initialize(xml)
    xml = ::LibXML::XML::Parser.string(xml) unless xml.class == LibXML::XML::Parser
    
    @raw, @name, @attributes = xml, xml.name, xml.attributes.to_h
    @children = xml.children.select(&:element?).group_by{|c|c.name.to_sym}
    
    text_value  = xml.children.select(&:text?).map(&:to_s).reject(&:empty?).join
    cdata_value = xml.children.select(&:cdata?).map{|c|c.to_s.chomp(']]>').sub('<![CDATA[', '')}.join
    @value = text_value.empty? ? cdata_value : text_value
  end

  def inspect
    terminal? ? value.inspect : "#<ROXO(#{name}):0x#{object_id.to_s(16)}>"
  end 

  def <=>(other)
    return z unless (z = self.class             <=> other.class            ).zero?
    return z unless (z = self.__attributes.sort <=> other.__attributes.sort).zero?
    return z unless (z = self.value             <=> other.value            ).zero?
    return z unless (z = self.name              <=> other.name             ).zero?

    our_nodes   =  self.children.values.flatten.map{|n|self.class.new(n)}
    their_nodes = other.children.values.flatten.map{|n|self.class.new(n)}

    our_nodes.sort <=> their_nodes.sort
  end

  def method_missing(sym, *args)
    if @children_by_name[sym]
      return self.class.new(@children_by_name[sym].first)
    elsif @attributes[sym.to_s]
      return @attributes[sym.to_s]
    elsif @children_by_name[sing = sym.to_s.singularize.to_sym]
      return @children_by_name[sing].map{|e|self.class.new(e)}
    end 
  end

end

