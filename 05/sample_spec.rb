# encoding: utf-8

describe Formatter do
  describe 'paragraphs' do
    it 'renders simple paragraphs' do
      expect_transformation 'Simple text', '<p>Simple text</p>'
    end

    it 'renders multiple paragraphs' do
      plain = <<-END
First line

Second line

Third line
END
      formatted = <<-END
<p>First line</p>

<p>Second line</p>

<p>Third line</p>
END

      expect_transformation plain, formatted
    end

    it 'breaks paragraphs with block-level elements' do
      plain = <<-END
First line
# Header!
Third line

Separate one
END

      formatted = <<-END
<p>First line</p>
<h1>Header!</h1>
<p>Third line</p>

<p>Separate one</p>
END

      expect_transformation plain, formatted
    end

    it 'escapes special entities' do
      plain = <<-END
Cats & Mice

Cool, <eh>?
END

      formatted = <<-END
<p>Cats &amp; Mice</p>

<p>Cool, &lt;eh&gt;?</p>
END

      expect_transformation plain, formatted
    end
  end

  describe 'headers' do
    it 'renders properly with the #, ##, ### and #### syntax' do
      expect_transformations({
        '# This is an H1'     => '<h1>This is an H1</h1>',
        '## This is an H2'    => '<h2>This is an H2</h2>',
        '### This is an H3'   => '<h3>This is an H3</h3>',
        '#### This is an H4'  => '<h4>This is an H4</h4>',
      })
    end

    it 'skips the malformed ones' do
      expect_transformations({
        '#No whitespace'         => '<p>#No whitespace</p>',
        '##### Header too small' => '<p>##### Header too small</p>',
        '###   '                 => '<p>###</p>',
      })
    end

    it 'escapes special entities' do
      expect_transformation '## Cash & "Carry"...', '<h2>Cash &amp; &quot;Carry&quot;...</h2>'
    end
  end

  describe 'code blocks' do
    it 'renders simple blocks' do
      expect_transformation '    This is a simple code block', '<pre><code>This is a simple code block</code></pre>'
    end

    it 'renders multiline blocks with empty lines' do
      plain = <<-END
    require 'gravity'
    
    # I'm flying now! Just like in Python!
END

      formatted = <<-END
<pre><code>require 'gravity'

# I'm flying now! Just like in Python!</code></pre>
END

      expect_transformation plain, formatted
    end

    it 'renders multiple ones' do
      plain = <<-END
    First block of code

    Second block of code
END

      formatted = <<-END
<pre><code>First block of code</code></pre>

<pre><code>Second block of code</code></pre>
END

      expect_transformation plain, formatted
    end

    it 'escapes special entities' do
      expect_transformation '    quote = "Simple & efficient";', '<pre><code>quote = &quot;Simple &amp; efficient&quot;;</code></pre>'
    end

    it 'renders properly with mixed content' do
      plain = <<-END
# This is a header

Some parahraphs

    Some clean code
    Which is also beautiful
    And maybe also compiles!

More paragraphs?
END

      formatted = <<-END
<h1>This is a header</h1>

<p>Some parahraphs</p>

<pre><code>Some clean code
Which is also beautiful
And maybe also compiles!</code></pre>

<p>More paragraphs?</p>
END

      expect_transformation plain, formatted
    end
  end

  describe 'blockquotes' do
    it 'renders simple ones' do
      expect_transformation '> Simple quote', '<blockquote><p>Simple quote</p></blockquote>'
    end

    it 'renders multiline ones' do
      plain = <<-END
> First line
> Second line
> Third line
END

      formatted = <<-END
<blockquote><p>First line
Second line
Third line</p></blockquote>
END

      expect_transformation plain, formatted
    end

    it 'renders multiline ones with multiple paragraphs' do
      plain = <<-END
> First quote
> 
> Second quote
END

      formatted = <<-END
<blockquote><p>First quote</p>

<p>Second quote</p></blockquote>
END

      expect_transformation plain, formatted
    end
  end

  describe 'links' do
    it 'renders simple links' do
      expect_transformation '[Programming in Ruby](http://fmi.ruby.bg/)', '<p><a href="http://fmi.ruby.bg/">Programming in Ruby</a></p>'
    end

    it 'does not render multiline or broken links' do
      expect_transformations({
        'This is [clearly] (broken)!' => '<p>This is [clearly] (broken)!</p>',
        'This one [is broken (too)]!' => '<p>This one [is broken (too)]!</p>',
        'The wind [is blowing (here)!' => '<p>The wind [is blowing (here)!</p>',
      })
    end

    it 'escapes special entities in the link description' do
      expect_transformation 'Testing [special & "entities" <b>](here).',
                            '<p>Testing <a href="here">special &amp; &quot;entities&quot; &lt;b&gt;</a>.</p>'
    end

    it 'escapes special entities in the link URL' do
      expect_transformation 'Or [what if](special & "entities" <b>) are in the URL?',
                            '<p>Or <a href="special &amp; &quot;entities&quot; &lt;b&gt;">what if</a> are in the URL?</p>'
    end
  end

  describe 'lists' do
    it 'renders simple unordered lists' do
      plain = <<-END
* Едно
* Друго
* Трето...
END

      formatted = <<-END
<ul>
  <li>Едно</li>
  <li>Друго</li>
  <li>Трето...</li>
</ul>
END

      expect_transformation plain, formatted
    end

    it 'renders simple ordered lists' do
      plain = <<-END
1. Първо
2. Второ
3. Трето...
END

      formatted = <<-END
<ol>
  <li>Първо</li>
  <li>Второ</li>
  <li>Трето...</li>
</ol>
END

      expect_transformation plain, formatted
    end

    it 'does not choke on malformed lists' do
      plain = <<-END
1) Първо
2 Второ
3.Трето
4. Четвърто
END

      formatted = <<-END
<p>1) Първо
2 Второ
3.Трето</p>
<ol>
  <li>Четвърто</li>
</ol>
END

      expect_transformation plain, formatted
    end

    it 'escapes special entities in the list elements' do
      plain = <<-END
* The && and || logical operators
* The `"` symbol
END

      formatted = <<-END
<ul>
  <li>The &amp;&amp; and || logical operators</li>
  <li>The `&quot;` symbol</li>
</ul>
END

      expect_transformation plain, formatted
    end

    it 'allows links in list elements' do
      plain = <<-END
* A [simple link]( here )?
END

      formatted = <<-END
<ul>
  <li>A <a href=" here ">simple link</a>?</li>
</ul>
END

      expect_transformation plain, formatted
    end
  end

  describe 'bold and italic text rendering' do
    it 'works in paragraphs' do
      expect_transformations({
        '_Simplest case_'   => '<p><em>Simplest case</em></p>',
        '**Simplest case**' => '<p><strong>Simplest case</strong></p>',
      })
    end

    it 'allows multiple ones per line' do
      expect_transformation 'Some _more words_ _to be_ **emphasized**, okay?',
                            '<p>Some <em>more words</em> <em>to be</em> <strong>emphasized</strong>, okay?</p>'
    end

    it 'works in headers' do
      expect_transformations({
        '# _Simplest case_'    => '<h1><em>Simplest case</em></h1>',
        '## **Simplest case**' => '<h2><strong>Simplest case</strong></h2>',
      })
    end

    it 'does not render in code blocks' do
      expect_transformation '    Some _more words_ _to be_ **emphasized**, okay?',
                            '<pre><code>Some _more words_ _to be_ **emphasized**, okay?</code></pre>'
    end

    it 'works in links' do
      expect_transformation 'Some [_more words_ _to be_ **emphasized**](okay)?',
                            '<p>Some <a href="okay"><em>more words</em> <em>to be</em> <strong>emphasized</strong></a>?</p>'
    end

    it 'works in list elements' do
      plain = '* Some _more words_ _to be_ **emphasized**.'
      formatted = <<-END
<ul>
  <li>Some <em>more words</em> <em>to be</em> <strong>emphasized</strong>.</li>
</ul>
END

      expect_transformation plain, formatted
    end

    it 'works in links in list elements' do
      plain = '* Some [_more words_ _to be_ **emphasized**](okay)?'
      formatted = <<-END
<ul>
  <li>Some <a href="okay"><em>more words</em> <em>to be</em> <strong>emphasized</strong></a>?</li>
</ul>
END

      expect_transformation plain, formatted
    end

    it 'does not brake HTML entities inside it' do
      expect_transformation 'Some _more & words_ _to be_ **"emphasized"**.',
                            '<p>Some <em>more &amp; words</em> <em>to be</em> <strong>&quot;emphasized&quot;</strong>.</p>'
    end

    it 'does not allow parial overlapping' do
      expect_transformation 'Some _more words **to be_ emphasized**.',
                            '<p>Some <em>more words **to be</em> emphasized**.</p>'
    end

    it 'allows simple nesting' do
      expect_transformation 'Some _more words **to be** emphasized_.',
                            '<p>Some <em>more words <strong>to be</strong> emphasized</em>.</p>'
      expect_transformation 'Some **more words _to be_ emphasized**.',
                            '<p>Some <strong>more words <em>to be</em> emphasized</strong>.</p>'
    end
  end

  describe 'special entities' do
    it 'escapes them in paragraphs' do
      expect_transformations({
        '"Black & Decker"' => '<p>&quot;Black &amp; Decker&quot;</p>',
      })
    end

    it 'escapes them in headers' do
      expect_transformations({
        '## "Black & Decker"' => '<h2>&quot;Black &amp; Decker&quot;</h2>',
      })
    end

    it 'escapes them in code blocks' do
      expect_transformations({
        '    brand = "Black & Decker"' => '<pre><code>brand = &quot;Black &amp; Decker&quot;</code></pre>',
      })
    end

    it 'escapes them in blockquotes' do
      expect_transformations({
        '> "Black & Decker"' => '<blockquote><p>&quot;Black &amp; Decker&quot;</p></blockquote>',
      })
    end

    it 'escapes them in deeply-nested elements' do
      expect_transformations({
        '## _"Black & Decker"_' => '<h2><em>&quot;Black &amp; Decker&quot;</em></h2>',
      })
    end
  end

  describe 'whitespace' do
    it 'removes excess leading and trailing whitespace' do
      expect_transformations({
        "\n\nSome text"                     => '<p>Some text</p>',
        "Some text\n\n"                     => '<p>Some text</p>',
        "\n\nSome text\n\n"                 => '<p>Some text</p>',
        "   \n   \n   Some text   \n  \n  " => '<p>Some text</p>',
      })
    end

    it 'ignores leading and trailing whitespace of lines whenever possible' do
      expect_transformations({
        "   A line   "                    => '<p>A line</p>',
        "First one  \n\n  Second one"     => "<p>First one</p>\n\n<p>Second one</p>",
        " #    Test with a header   \n\n" => '<h1>Test with a header</h1>',
      })
    end

    it 'does not touch trailing whitespace in code blocks' do
      expect_transformations({
        "    Simple code block  "               => '<pre><code>Simple code block  </code></pre>',
        "    First  \n      Second  \n\n"       => "<pre><code>First  \n  Second  </code></pre>",
        "    First  \n      \n     Second \n\n" => "<pre><code>First  \n  \n Second </code></pre>",
      })
    end
  end

  describe 'public interface' do
    it 'implements #to_html' do
      Formatter.new('').should respond_to :to_html
      Formatter.new('Simple').to_html.should eq '<p>Simple</p>'
    end

    it 'implements #to_s' do
      Formatter.new('').should respond_to :to_s
      Formatter.new('Simple').to_s.should eq '<p>Simple</p>'
    end

    it 'implements #inspect' do
      Formatter.new('').should respond_to :inspect
      Formatter.new('Simple').inspect.should eq 'Simple'
      Formatter.new(' Simple with ws ').inspect.should eq ' Simple with ws '
    end
  end

  describe 'mixed, complex input' do
    it 'renders properly' do
      plain = <<-END
# Цялостен пример
Тук ще демонстрираме накратко възможностите на нашия прост Markdown-интерпретатор.

## _Философия_ на [Markdown](http://daringfireball.net/projects/markdown/syntax#philosophy)

Кратък цитат относно философията на Markdown:
> Markdown is intended to be as easy-to-read and easy-to-write as is feasible.
> 
> Readability, however, is emphasized above all else. A Markdown-formatted document should be publishable as-is, as plain text, without looking like it’s been marked up with tags or formatting instructions.
Повече информация може да намерите на [сайта на **Markdown**](http://daringfireball.net/projects/markdown).

## Предимства

Създаването на съдържание във формата Markdown има множество предимства.

Ето някои от тях:
* Лесно четим в _суров_ вид
* Без "скрити" форматиращи тагове — форматирането ви никога не се чупи
* След обработка може да изглежда много добре

## Поддръжка в _Ruby_

В **Ruby** има множество Gem-ове, които могат да ви помогнат за да прехвърляте Markdown-съдържание в HTML-формат.
Кодът, който вие създавате, също може да върши това до известна степен.

Пример за употреба на вашия код:

    # Много просто
    formatter = Formatter.new "## My Markdown"
    puts formatter.to_html
END

      formatted = <<-END
<h1>Цялостен пример</h1>
<p>Тук ще демонстрираме накратко възможностите на нашия прост Markdown-интерпретатор.</p>

<h2><em>Философия</em> на <a href="http://daringfireball.net/projects/markdown/syntax#philosophy">Markdown</a></h2>

<p>Кратък цитат относно философията на Markdown:</p>
<blockquote><p>Markdown is intended to be as easy-to-read and easy-to-write as is feasible.</p>

<p>Readability, however, is emphasized above all else. A Markdown-formatted document should be publishable as-is, as plain text, without looking like it’s been marked up with tags or formatting instructions.</p></blockquote>
<p>Повече информация може да намерите на <a href="http://daringfireball.net/projects/markdown">сайта на <strong>Markdown</strong></a>.</p>

<h2>Предимства</h2>

<p>Създаването на съдържание във формата Markdown има множество предимства.</p>

<p>Ето някои от тях:</p>
<ul>
  <li>Лесно четим в <em>суров</em> вид</li>
  <li>Без &quot;скрити&quot; форматиращи тагове — форматирането ви никога не се чупи</li>
  <li>След обработка може да изглежда много добре</li>
</ul>

<h2>Поддръжка в <em>Ruby</em></h2>

<p>В <strong>Ruby</strong> има множество Gem-ове, които могат да ви помогнат за да прехвърляте Markdown-съдържание в HTML-формат.
Кодът, който вие създавате, също може да върши това до известна степен.</p>

<p>Пример за употреба на вашия код:</p>

<pre><code># Много просто
formatter = Formatter.new &quot;## My Markdown&quot;
puts formatter.to_html</code></pre>
END

      expect_transformation plain, formatted
    end
  end

  def expect_transformation(plain, formatted)
    Formatter.new(plain).to_html.should eq formatted.strip
  end

  def expect_transformations(table)
    table.each do |plain, formatted|
      expect_transformation plain, formatted
    end
  end
end
