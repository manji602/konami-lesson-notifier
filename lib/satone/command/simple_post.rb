module Satone
  module Command
    class SimplePost < Base
      # 定型文をpostする際に便利なcommand moduleです。
      # config/simple_post.yamlに `name` をkeyとした文章を追加し、
      # `Satone::Command::SimplePost.execute params: { name: hoge }` とすると
      # post したい内容を取得できます。

      def self.execute(params: {})
        name = params[:name]

        return nil if name.nil?

        yaml_file = File.expand_path(File.dirname(__FILE__) + "/../../../config/simple_post.yaml")
        message = YAML.load_file(yaml_file)[name.to_s]

        { text: message }
      end
    end
  end
end
