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
          ['--root', 'Flutter SDK path default FLUTTER_ROOT.'],
          ['--application-path', 'Flutter Project path defalut is Dir.pwd.'],
          ['--target', 'Flutter target default is lib/main.dart.'],
          ['--build-mode', 'Flutter build model, debug、release(default)'],
          ['--build-dir', 'Flutter build dir, default build.'],
          ['--derived-dir', 'Flutter derived dir, default Flutter'],
          ['--application-frame-name', 'Flutter applicationFrame Name, default App'],
        ]
      end

      def initialize(argv)
        @flutter_root = argv.option('root', ENV['FLUTTER_ROOT'])
        @flutter_application_path = argv.option('application-path', ENV['FLUTTER_APPLICATION_PATH']) || Dir.pwd
        @flutter_target = argv.option('target', ENV['FLUTTER_TARGET']) || 'lib/main.dart'
        @flutter_build_mode = argv.option('build-mode', ENV['FLUTTER_BUILD_MODE']) || 'debug'
        @flutter_build_dir = argv.option('build-dir', ENV['FLUTTER_BUILD_DIR']) || 'build'
        @flutter_derived_dir = argv.option('derived-dir', 'Flutter')
        @flutter_application_frame_name = argv.option('application-frame-name', 'App')
        super
      end

      def validate!
        super
        help! 'FLUTTER_ROOT is required.' unless @flutter_root
        @flutter_root = File.expand_path(@flutter_root)

        help! 'application-path is required.' unless File.exist?(@flutter_application_path)

        @flutter_target = File.expand_path(@flutter_target, @flutter_application_path)
        help! 'target is required.' unless File.exist?(@flutter_target)

        help! 'build-mode is required.' unless @flutter_build_mode
      end

      def run
        copy_framework
        build
      end

      def copy_framework
        # 拷贝framework
        flutter_artifact_variant = nil
        case @flutter_build_mode.downcase
        when 'release'
          flutter_artifact_variant = 'ios-release'
        when 'profile'
          flutter_artifact_variant = 'ios-profile'
        when 'debug'
          flutter_artifact_variant = 'ios'
        end
        help! "Unknown FLUTTER_BUILD_MODE: #{@flutter_build_mode}" unless flutter_artifact_variant

        framework_path = File.join(@flutter_root, 'bin/cache/artifacts/engine/', flutter_artifact_variant)
        enginePath = File.join(@flutter_derived_dir,'engine/')
        system "rm -rf -- #{enginePath}"
        system "mkdir -p -- #{enginePath}"
        system "cp -r -- #{framework_path}/Flutter.podspec #{enginePath}"
        system "cp -r -- #{framework_path}/Flutter.framework #{enginePath}"
        system "find \"#{enginePath}/Flutter.framework\" -type f -exec chmod a-w \"{}\" \\;"
      end
      
      def thin; end
    end
  end
end
