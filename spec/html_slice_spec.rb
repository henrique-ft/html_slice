# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
RSpec.describe HtmlSlice do
  let(:html_generator) { Class.new { include HtmlSlice }.new }

  describe "#html_layout" do
    it "generates a html slice with DOCTYPE html" do
      html_generator.html_layout do
        div do
          h1 { _("Hello World") }
        end
      end
      result = html_generator.html_slice
      expect(result).to eq("<!DOCTYPE html><html><div><h1>Hello World</h1></div></html>")
    end
  end

  describe "#html_slice" do
    it "generates a html slice" do
      html_generator.html_slice do
        div do
          h1 { _("Hello World") }
        end
      end
      result = html_generator.html_slice
      expect(result).to eq("<div><h1>Hello World</h1></div>")
    end
  end

  describe "simple tag generation" do
    it "generates a self-closing tag without content" do
      html_generator.html_slice do
        meta charset: "UTF-8"
      end
      result = html_generator.html_slice
      expect(result).to include("<meta charset='UTF-8'/>")
    end

    it "generates a tag with content" do
      html_generator.html_slice do
        h1 "Welcome"
      end
      result = html_generator.html_slice
      expect(result).to include("<h1>Welcome</h1>")
    end
  end

  describe "nested tags" do
    it "generates nested HTML tags" do
      html_generator.html_slice do
        div do
          h1 { _("Header") }
          tag :p, "Paragraph content"
        end
      end
      result = html_generator.html_slice
      expect(result).to include("<div><h1>Header</h1><p>Paragraph content</p></div>")
    end
  end

  describe "tags with attributes" do
    it "generates a tag with attributes" do
      html_generator.html_slice do
        a "Click here", href: "https://example.com", target: "_blank"
      end
      result = html_generator.html_slice
      expect(result).to include("<a href='https://example.com' target='_blank'>Click here</a>")
    end

    it "generates nested tags with attributes" do
      html_generator.html_slice do
        div class: "container" do
          span "Label", class: "label-class"
        end
      end
      result = html_generator.html_slice
      expect(result).to include("<div class='container'><span class='label-class'>Label</span></div>")
    end
  end

  describe "block content handling" do
    it "handles plain text inside a block" do
      html_generator.html_slice do
        tag :p do
          _ "This is a paragraph."
        end
      end
      result = html_generator.html_slice
      expect(result).to include("<p>This is a paragraph.</p>")
    end

    it "handles nested blocks" do
      html_generator.html_slice do
        ul do
          li { _("Item 1") }
          li { _("Item 2") }
        end
      end
      result = html_generator.html_slice
      expect(result).to include("<ul><li>Item 1</li><li>Item 2</li></ul>")
    end
  end

  it "we can add ids to html slice" do
    html_generator.html_slice :header do
      div do
        h1 { _("Hello World") }
      end
    end
    result = html_generator.html_slice :header
    expect(result).to eq("<div><h1>Hello World</h1></div>")
  end

  it "we can run tag methods without html_slice init" do
    html_generator.tag :header do
      meta charset: "utf-8"
    end
    result = html_generator.div do
      h1 "hello"
    end
    expect(result).to eq("<header><meta charset='utf-8'/></header><div><h1>hello</h1></div>")
  end

  describe "wrapping" do
    it "append wrap content in start and end of result" do
      html_generator.html_slice wrap: %w[some thing] do
        img src: "image.png", alt: "An image"
      end
      result = html_generator.html_slice
      expect(result).to include("some<img src='image.png' alt='An image'/>thing")
    end
  end

  describe "special cases" do
    it "generates a self-closing tag for img" do
      html_generator.html_slice do
        img src: "image.png", alt: "An image"
      end
      result = html_generator.html_slice
      expect(result).to include("<img src='image.png' alt='An image'/>")
    end

    it "handles attributes with underscores" do
      html_generator.html_slice do
        link rel: "stylesheet", href: "styles.css", data_test_id: "1234"
      end
      result = html_generator.html_slice
      expect(result).to include("<link rel='stylesheet' href='styles.css' data-test-id='1234'/>")
    end

    describe "scaping html" do
      it do
        html_generator.html_slice do
          div "background-color: #gray;"
          div "alert('hello spec')"
        end
        result = html_generator.html_slice
        expect(result).to include("<div>background-color: #gray;</div><div>alert(&#39;hello spec&#39;)</div>")
      end
      it "dont scape html for 'style' and 'script' tags" do
        html_generator.html_slice do
          style "background-color: #gray;"
          script "alert('hello spec')"
        end
        result = html_generator.html_slice
        expect(result).to include("<style>background-color: #gray;</style><script>alert('hello spec')</script>")
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
