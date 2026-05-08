# frozen_string_literal: true

require "spec_helper"
require "html_slice/rails" # Ensure the module under test is loaded

module Rails
  module Application
    module Routes
      module UrlHelpers
      end

      def self.url_helpers
        UrlHelpers
      end
    end

    def self.routes
      Routes
    end
  end

  def self.application
    Application
  end
end

module ActionView
  module RecordIdentifier; end

  module Helpers
    module FormHelper; end
    module FormOptionsHelper; end
    module TranslationHelper; end
    module UrlHelper; end
  end
end

class DummyViewContext
  include HtmlSlice::Rails
end

RSpec.describe HtmlSlice::Rails do
  let(:dummy_view_context) { DummyViewContext.new }

  # Test that the correct modules are included
  it "includes ActionView::RecordIdentifier" do
    expect(DummyViewContext.ancestors).to include(ActionView::RecordIdentifier)
  end

  it "includes ActionView::Helpers::FormHelper" do
    expect(DummyViewContext.ancestors).to include(ActionView::Helpers::FormHelper)
  end

  it "includes ActionView::Helpers::FormOptionsHelper" do
    expect(DummyViewContext.ancestors).to include(ActionView::Helpers::FormOptionsHelper)
  end

  it "includes ActionView::Helpers::TranslationHelper" do
    expect(DummyViewContext.ancestors).to include(ActionView::Helpers::TranslationHelper)
  end

  it "includes ActionView::Helpers::UrlHelper" do
    expect(DummyViewContext.ancestors).to include(ActionView::Helpers::UrlHelper)
  end

  it "includes Rails.application.routes.url_helpers" do
    # We need to get the actual module returned by Rails.application.routes.url_helpers
    # to check for its inclusion.
    expect(DummyViewContext.ancestors).to include(Rails.application.routes.url_helpers)
  end

  it "includes HtmlSlice" do
    expect(DummyViewContext.ancestors).to include(HtmlSlice)
  end
end
