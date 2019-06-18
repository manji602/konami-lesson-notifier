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

  describe ".is_target_information?" do
    subject { Satone::Command::KonamiAlternateNotifier.is_target_information? title, body }

    shared_examples_for "common spec" do
      it "returns expected result" do
        expect(subject).to be expected_result
      end
    end

    context "title not includes TITLE_KEYWORDS" do
      let(:title) { "【2017年1月～3月スタジオ予約参加対象クラス】" }
      let(:body) { "hogehoge" }
      let(:expected_result) { false }

      it_behaves_like "common spec"
    end


    context "title includes TITLE_KEYWORDS" do
      context "title includes LESSON_KEYWORDS" do
        let(:title) { "X55 AA -> BB 代行" }
        let(:body) { "" }
        let(:expected_result) { true }

        it_behaves_like "common spec"
      end

      context "body includes LESSON_KEYWORDS" do
        let(:title) { "hugahuga 代行のご案内" }
        let(:body) { "ボディパンプ AA -> BB" }
        let(:expected_result) { true }

        it_behaves_like "common spec"
      end

      context "neither title nor body includes LESSON_KEYWORDS" do
        let(:title) { "piyopiyo 代行のご案内" }
        let(:body) { "水泳 AA -> BB" }
        let(:expected_result) { false }

        it_behaves_like "common spec"
      end
    end
  end
end
