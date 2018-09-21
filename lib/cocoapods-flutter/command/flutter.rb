module Pod
  class Command
    class Flutter < Command
      self.summary = 'Short description of cocoapods-flutter.'

      self.description = <<-DESC
        Longer description of cocoapods-flutter.
      DESC

      self.arguments = []

      def self.options
        [
          ['--root', 'FLUTTER.'],
          ['--application-path', 'FLUTTER.'],
          ['--target', 'FLUTTER.'],
          ['--build-model', 'Debug,Release'],
          ['--build-dir', 'FLUTTER.'],
          ['--build-name', 'FLUTTER.'],
          ['--build-number', 'FLUTTER.']
        ]
      end

      def initialize(argv)
        @flutter_root = argv.option('root', ENV['FLUTTER_ROOT'])
        @flutter_application_path = argv.option('application-path', Dir.pwd)
        @flutter_target = argv.option('target', 'lib/main.dart')
        @flutter_build_model = argv.option('build-model', 'Release')
        @flutter_build_dir = argv.option('build-dir', 'build')
        @flutter_build_name = argv.option('build-name', '1.0.0')
        @flutter_build_number = argv.option('build-number', '1')
        super
      end

      def validate!
        super
        # help! 'A Pod name is required.' unless @name
      end

      def run; end

      def build
        # config by build-model
        artifact_variant = 'ios'

        framework_path = File.join(@flutter_root, '/bin/cache/artifacts/engine/', @artifact_variant)

        # assembling Flutter resource
        `#{@flutter_root}/bin/flutter --suppress-analytics      \
        build bundle                                            \
        --target-platform=ios                                   \
        --target="#{@flutter_target}"                           \
        --snapshot="#{@flutter_build_dir}/snapshot_blob.bin"    \
        --#{@flutter_build_mode}                                \
        --depfile="#{@flutter_build_dir}/snapshot_blob.bin.d"   \
        --asset-dir="#{@flutter_build_dir}/flutter_assets"             \
        `
      end

      def thin; end
    end
  end
end
