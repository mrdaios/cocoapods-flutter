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
          # ['--build-name', 'Flutter build name.'],
          # ['--build-number', 'Flutter build number.'],
          ['--derived-dir', 'Flutter derived dir, default Flutter'],
          ['--application-frame-name', 'Flutter applicationFrame Name, default App'],

          ['--local-engine', 'TRACK_WIDGET_CREATION.'],
          ['--track-widget-creation-flag', 'LOCAL_ENGINE.'],
          ['--verbose', 'VERBOSE_SCRIPT_LOGGING.']
        ]
      end

      def initialize(argv)
        @flutter_root = File.expand_path(argv.option('root', ENV['FLUTTER_ROOT']))
        @flutter_application_path = argv.option('application-path', Dir.pwd)
        @flutter_target = File.expand_path(argv.option('target', 'lib/main.dart'))
        @flutter_build_mode = argv.option('build-mode', 'debug')
        @flutter_build_dir = argv.option('build-dir', 'build')
        @flutter_build_name = argv.option('build-name', '1.0.0')
        @flutter_build_number = argv.option('build-number', '1')
        @flutter_derived_dir = argv.option('derived-dir', 'Flutter')
        @flutter_artifact_variant = nil
        @flutter_application_frame_name = argv.option('application-frame-name', 'App')

        @flutter_local_engine = argv.option('local-engine', ENV['LOCAL_ENGINE'])
        @flutter_track_widget_creation_flag = argv.flag?('track-widget-creation-flag', ENV['TRACK_WIDGET_CREATION'])
        @flutter_verbose = argv.flag?('verbose', ENV['VERBOSE_SCRIPT_LOGGING'])
        super
      end

      def validate!
        super
        help! 'FLUTTER_ROOT is required.' unless @flutter_root
        help! 'application-path is required.' unless File.exist?(@flutter_application_path)
        help! 'target is required.' unless File.exist?(@flutter_target)
        help! 'build-mode is required.' unless @flutter_build_mode
      end

      def run
        copy_framework
        build
      end

      def copy_framework
        # 拷贝framework
        case @flutter_build_mode
        when 'release'
          @flutter_artifact_variant = 'ios-release'
        when 'profile'
          @flutter_artifact_variant = 'ios-profile'
        when 'debug'
          @flutter_artifact_variant = 'ios'
        end
        help! "Unknown FLUTTER_BUILD_MODE: #{@flutter_build_mode}" unless @flutter_artifact_variant

        framework_path = File.join(@flutter_root, 'bin/cache/artifacts/engine/', @flutter_artifact_variant)
        runnerPath = File.join(@flutter_application_path, '.ios/')
        if File.exist?(runnerPath)
          enginePath = File.join(runnerPath,'flutter/engine')
          system "rm -rf -- #{enginePath}"
          system "mkdir -p -- #{enginePath}"

          system "cp -r -- #{framework_path}/Flutter.podspec #{enginePath}"
          system "cp -r -- #{framework_path}/Flutter.framework #{enginePath}"
          system "find \"#{enginePath}/Flutter.framework\" -type f -exec chmod a-w \"{}\" \\;"
        else
          system "rm -rf -- #{@flutter_derived_dir}/Flutter.framework"
          system "mkdir -p -- #{@flutter_derived_dir}/Flutter.framework"

          system "cp -r -- #{framework_path}/Flutter.podspec #{@flutter_derived_dir}"
          system "cp -r -- #{framework_path}/Flutter.framework #{@flutter_derived_dir}"
          system "find \"#{@flutter_derived_dir}/Flutter.framework\" -type f -exec chmod a-w \"{}\" \\;"
        end
      end

      def putConfig
        puts <<-EOF
FLUTTER_ROOT=#{@flutter_root}
FLUTTER_APPLICATION_PATH=#{@flutter_application_path}
FLUTTER_TARGET=#{@flutter_target}
FLUTTER_DERIVED_DIR=#{@flutter_derived_dir}
FLUTTER_BUILD_MODE=#{@flutter_build_mode}
FLUTTER_BUILD_DIR=#{@flutter_build_dir}
FLUTTER_BUILD_NAME=#{@flutter_build_name}
FLUTTER_BUILD_NUMBER=#{@flutter_build_number}
        EOF
      end

      def thin; end
    end
  end
end
