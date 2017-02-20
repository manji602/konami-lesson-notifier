module Satone
  module Command
    class KonamiAlternateNotifier < Base
      PRETEXT = "コナミスポーツクラブの代行案内が更新されたよ！"
      FALLBACK_TEXT = "テキストの展開に失敗しました。"
      INFORMATION_URL_PREFIX = "http://information.konamisportsclub.jp/newdesign/"
      CRAWL_TARGETS = [
        { url: "#{INFORMATION_URL_PREFIX}timetable.php?Facility_cd=007871",
          name: "コナミスポーツクラブ 渋谷",
          file_prefix: "shibuya"
        },
        { url: "#{INFORMATION_URL_PREFIX}timetable.php?Facility_cd=004446",
          name: "コナミスポーツクラブ 目黒青葉台",
          file_prefix: "nakameguro"
        },
        { url: "#{INFORMATION_URL_PREFIX}timetable.php?Facility_cd=006034",
          name: "コナミスポーツクラブ 碑文谷",
          file_prefix: "gakugeidaigaku"
        },
        { url: "#{INFORMATION_URL_PREFIX}timetable.php?Facility_cd=006029",
          name: "コナミスポーツクラブ 自由が丘駅前",
          file_prefix: "jiyuugaoka"
        },
        { url: "#{INFORMATION_URL_PREFIX}timetable.php?Facility_cd=004070",
          name: "コナミスポーツクラブ 武蔵小杉",
          file_prefix: "musashikosugi"
        },
        { url: "#{INFORMATION_URL_PREFIX}timetable.php?Facility_cd=004479",
          name: "コナミスポーツクラブ 川崎",
          file_prefix: "kawasaki"
        }
      ]

      # 代行情報のフィルタリング

      # タイムテーブル更新情報のhtmlのうち、以下のキーワードを含むURLを取得する"
      HTML_KEYWORD    = "代行"
      # 以下のレッスンを含む代行情報のみ表示する
      LESSON_KEYWORDS = %w{ボディパンプ ボディコンバット コアクロス エクストリーム55 X55}
      
      def self.execute(params: {})
        updates = []

        CRAWL_TARGETS.each do |crawl_target|
          result = crawl_update_information crawl_target

          if result[:is_updated]
            updates.push result[:updates]
            save_updates prefix: crawl_target[:file_prefix], updates: result[:updates]
          end
        end

        build_attachments updates.flatten
      end

      def self.crawl_update_information(crawl_target)
        url = crawl_target[:url]
        body = fetch_html url

        updates = []
        
        body.css('div#topics ul li a').each do |topic|
          next unless topic.text.include? HTML_KEYWORD

          # NOTE:
          # onclick属性に window.open('URLのsuffix'...)と続くので
          # シングルクォートでsplitした2番目の要素がURLのsuffixとなる
          url_suffix = topic['onclick'].split("'").second
          topic_url  = INFORMATION_URL_PREFIX + url_suffix
          
          topic_body = fetch_html topic_url

          topic_title = topic_body.css('h1').text
          topic_body  = topic_body.css('p.linkurl').text

          next unless is_target_information?(topic_title, topic_body)
          
          content = {
            title: topic_title,
            body: topic_body,
            url: topic_url,
            shop_name: crawl_target[:name]
          }

          updates.push content
        end

        is_updated = updated?(prefix: crawl_target[:file_prefix], latest_updates: updates)
        
        { is_updated: is_updated, updates: updates }
      end

      def self.is_target_information?(topic_title, topic_body)
        is_target_information = false
          
        LESSON_KEYWORDS.each do |lesson|
          is_target_information = true if topic_title.include? lesson
          is_target_information = true if topic_body.include? lesson
        end        

        is_target_information
      end
      
      def self.fetch_html(url)
        uri = URI url
        req = Net::HTTP::Get.new "#{uri.path}?#{uri.query}"
        response = Net::HTTP.start(uri.host, uri.port, use_ssl: false) { |http| http.request req }
        
        Nokogiri::HTML.parse(response.body, nil, "UTF-8")
      end

      def self.save_updates(prefix: nil, updates: [])
        return if prefix.nil? || updates.empty?
        
        file = file_name prefix
        file_manager = Satone::Helper::FileManager.new file

        file_manager.overwrite [updates.to_json]
      end

      def self.fetch_previous_updates(prefix)
        return [] if prefix.nil?

        file = file_name prefix
        file_manager = Satone::Helper::FileManager.new file

        return [] unless file_manager.file_exists?

        JSON.parse(file_manager.fetch_all.first, symbolize_names: true)
      end
      
      def self.updated?(prefix: nil, latest_updates: [])
        previous_updates = fetch_previous_updates prefix

        return true if previous_updates.size != latest_updates.size

        previous_updates.zip(latest_updates).each do |previous, latest|
          return true if previous[:body]  != latest[:body]
          return true if previous[:title] != latest[:title]
        end

        false
      end
      
      def self.file_name(file_prefix)
        "konami/updates_#{file_prefix}.txt"
      end
      
      def self.build_attachments(updates)
        return if updates.empty?

        attachments = []

        updates.each_with_index do |content, index|
          is_first = index.zero? ? true : false
          attachment = build_attachment content: content, is_first: is_first
          attachments.push attachment
        end

        {
          attachments: attachments
        }
      end

      def self.build_attachment(content: {}, is_first: false)
        pretext = is_first ? PRETEXT : ""

        {
          fallback: FALLBACK_TEXT,
          pretext: pretext,
          author_name: content[:shop_name],
          title: content[:title],
          title_link: content[:url],
          text: content[:body],
          color: "#36a64f"
        }
      end
    end
  end
end
