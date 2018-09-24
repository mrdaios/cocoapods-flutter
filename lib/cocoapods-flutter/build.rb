module Pod
  class Command
    class Flutter < Command
      def build
        verbose_flag = ''
        local_engine_flag = ''
        track_widget_creation_flag = ''

        # build framework
        if @flutter_build_mode != 'debug'
          puts ' ├─Building Dart code...'
          system "#{@flutter_root}/bin/flutter --suppress-analytics       \
          build aot                                                       \
          --output-dir=#{@flutter_build_dir}/aot                          \
          --target-platform=ios                                           \
          --target=\"#{@flutter_target}\"                                 \
          --#{@flutter_build_mode}                                        \
          #{local_engine_flag}                                            \
          #{track_widget_creation_flag}                                   \
          #{verbose_flag}                                                 \
          "
          puts 'done'

          system "cp -r -- \"#{@flutter_build_dir}/aot/#{@flutter_application_frame_name}.framework\" \"#{@flutter_derived_dir}\""
        else
          # Build stub for all requested architectures.
          system "mkdir -p -- \"#{File.join(@flutter_derived_dir, @flutter_application_frame_name)}.framework\""

          system "echo \"static const int Moo = 88;\" | xcrun clang -x c \
          -dynamiclib \
          -Xlinker -rpath -Xlinker '@executable_path/Frameworks' \
          -Xlinker -rpath -Xlinker '@loader_path/Frameworks' \
          -install_name '@rpath/#{@flutter_application_frame_name}.framework/#{@flutter_application_frame_name}' \
          -o \"#{File.join(@flutter_derived_dir, @flutter_application_frame_name)}.framework/#{@flutter_application_frame_name}\"
          "
          
        end

        # copy plist
        plistPath = File.join(@flutter_derived_dir, "#{@flutter_application_frame_name}.framework/Info.plist")
        system "/usr/libexec/PlistBuddy -c \"Clear\" #{plistPath}"
        system "/usr/libexec/PlistBuddy -c \"Add :CFBundleDevelopmentRegion string en\" #{plistPath}"
        system "/usr/libexec/PlistBuddy -c \"Add :CFBundleExecutable string #{@flutter_application_frame_name}\" #{plistPath}"
        system "/usr/libexec/PlistBuddy -c \"Add :FLTAssetsPath string #{@flutter_application_frame_name}.bundle\" #{plistPath}"

        # build bundle
        precompilation_flag = ""
        ENV["CURRENT_ARCH"]="x86-64"
        if ENV["CURRENT_ARCH"] != "x86-64" && @flutter_build_mode != "debug"
            precompilation_flag = "--precompiled"
        end

        puts " ├─Assembling Flutter resources..."
        system "cd #{@flutter_application_path}&&#{@flutter_root}/bin/flutter --suppress-analytics       \
        build bundle                                                    \
        --target-platform=ios                                           \
        --target=\"#{@flutter_target}\"                                 \
        --snapshot=\"#{@flutter_build_dir}/snapshot_blob.bin\"          \
        --#{@flutter_build_mode}                                        \
        --depfile=\"#{@flutter_build_dir}/snapshot_blob.bin.d\"         \
        --asset-dir=\"#{File.join(@flutter_derived_dir, "#{@flutter_application_frame_name}.bundle")}\"          \
        #{precompilation_flag}                                          \
        #{local_engine_flag}                                            \
        #{track_widget_creation_flag}                                   \
        #{verbose_flag}                                                 \
        "
        puts "done"
        puts " └─Compiling, linking and signing..."
      end
    end
  end
end
