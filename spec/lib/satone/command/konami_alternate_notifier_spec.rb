require "spec_helper"

RSpec.describe Satone::Command::KonamiAlternateNotifier do
  describe ".build_attachment" do
    let(:content) do
      {
        shop_name: "some shop",
        title: "some title",
        url: "some url",
        body: "some body"
      }
    end

    subject { Satone::Command::KonamiAlternateNotifier.build_attachment content: content, is_first: is_first }

    shared_examples_for "common spec" do
      it "returns attachment" do
        expect(subject[:author_name]).not_to be_nil
        expect(subject[:title]).not_to be_nil
        expect(subject[:title_link]).not_to be_nil
        expect(subject[:text]).not_to be_nil
      end
    end
    
    context "is_first is false" do
      let(:is_first) { false }

      it "returns empty pretext" do
        expect(subject[:pretext].empty?).to be_truthy
      end

      it_behaves_like "common spec"
    end

    context "is_first is true" do
      let(:is_first) { true }

      it "returns empty pretext" do
        expect(subject[:pretext].empty?).to be_falsey
      end

      it_behaves_like "common spec"
    end
  end
end
