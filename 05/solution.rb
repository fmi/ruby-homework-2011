class Formatter
  attr_reader :plain

  def initialize(plain)
    @plain = plain
  end

  def to_html
    @html ||= format_text
  end

  alias_method :to_s,    :to_html
  alias_method :inspect, :plain

  private

  def format_text
    parser = TextParser.new

    @plain.split("\n").each do |line|
      parser.parse line
    end

    parser.end.parsed.strip
  end
end

module WithContexts
  attr_reader :depth

  def initialize
    @depth    = 0
    @contexts = {}
  end

  def in_context(context = nil)
    close_contexts_at(depth) if context_at(depth) != context
    between_contexts
    context_opened(context)  if context_at(depth) != context

    @contexts[depth] = context

    @depth += 1
    yield if block_given?
    @depth -= 1
  end

  def close_contexts_at(depth)
    @contexts.keys.each do |context_depth|
      context_closed @contexts.delete(context_depth) if context_depth > depth
    end

    context_closed context_at(depth)
  end

  def context_at(depth)
    @contexts[depth]
  end

  def max_depth
    @contexts.keys.max || 0
  end

  def between_contexts
  end

  def context_opened(context)
  end

  def context_closed(context)
  end
end

module Html
  module Format
    def expand(context)
      context == :code ? [:pre, :code] : [context]
    end

    def open_tags_for(context)
      expand(context).map { |tag| aligned_open_tag(tag) }.join
    end

    def close_tags_for(context)
      expand(context).reverse.map { |tag| aligned_close_tag(tag) }.join
    end

    def aligned_open_tag(tag)
      html = "<#{tag}>"

      case tag
      when :li      then "  #{html}"
      when :ul, :ol then "#{html}\n"
      else html
      end
    end

    def aligned_close_tag(tag)
      html = "</#{tag}>"

      case tag
      when :ul, :ol then "\n#{html}"
      else html
      end
    end

    def contains_unmatched_tags?(html)
      tag_pattern = /<([a-z]+)[^>]*>(.*)<\/\1>/

      while (substitution = html.gsub(tag_pattern, '\2')) != html
        html = substitution
      end

      html =~ /<\/?([a-z]+)[^>]*>/
    end

    def anchor_tag(content, url)
      %Q(<a href="#{url}">#{content}</a>)
    end

    def method_missing(name, *args)
      if name =~ /^([a-z]+)_tag$/
        "<#{$1}>#{args.first}</#{$1}>"
      else
        super
      end
    end
  end

  module Entities
    ENTITIES = {
      '&' => '&amp;',
      '"' => '&quot;',
      '<' => '&lt;',
      '>' => '&gt;',
    }.freeze

    ENTITY_PATTERN = /#{ENTITIES.keys.join('|')}/.freeze

    def escape(text)
      text.gsub ENTITY_PATTERN, ENTITIES
    end
  end
end

module BlockLevelElements
  def p(line)
    element :p, line
  end

  def h(size, line)
    element "h#{size}", line
  end

  def blank(line)
    element nil, line
  end

  def code(line)
    in_context :code do
      @parsed << escape(line)
    end
  end

  def blockquote(line)
    in_context :blockquote do
      parse line
    end
  end

  def list(type, line)
    in_context type do
      @parsed << open_tags_for(:li)
      @parsed << format_line(line.strip)
      @parsed << close_tags_for(:li)
    end
  end

  def element(context, line)
    in_context context do
      @parsed << format_line(line.strip)
    end
  end
end

class TextParser
  include WithContexts
  include Html::Format
  include Html::Entities
  include BlockLevelElements

  attr_reader :parsed

  def initialize
    super
    @parsed = ''
  end

  def parse(line)
    case line
    when /^    (.*)$/               then code $1
    when /^\s*$/                    then blank line
    when /^\s*(\#{1,4})\s+(\S.*)$/  then h $1.size, $2
    when /^\s*>\s+(.*)$/            then blockquote $1
    when /^\s*\*\s+(.*)$/           then list :ul, $1
    when /^\s*\d+\.\s+(.*)$/        then list :ol, $1
    else                                 p line
    end
  end

  def context_opened(context)
    @parsed << open_tags_for(context) if context
  end

  def between_contexts
    @parsed << "\n" if @parsed != '' and depth == max_depth
  end

  def context_closed(context)
    @parsed << close_tags_for(context) if context
  end

  def format_line(line)
    LineParser.new(line).parsed
  end

  def end
    in_context nil
    @parsed.freeze

    self
  end
end

class LineParser
  include Html::Format
  include Html::Entities

  attr_reader :parsed

  def initialize(line)
    [:escape, :links, :em, :strong].each do |processor|
      line = send(processor, line)
    end

    @parsed = line
  end

  def links(line)
    line.gsub /\[(.+?)\]\((.+?)\)/ do
      anchor_tag $1, $2
    end
  end

  def em(line)
    line.gsub /_(.*?)_/ do |original|
      contains_unmatched_tags?($1) ? original : em_tag($1)
    end
  end

  def strong(line)
    line.gsub /\*\*(.*?)\*\*/ do |original|
      contains_unmatched_tags?($1) ? original : strong_tag($1)
    end
  end
end
