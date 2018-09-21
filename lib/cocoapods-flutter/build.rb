module Pod
  class Command
    class Flutter < Command
      def build
        verbose_flag = @flutter_verbose ? '--verbose' : ''
        local_engine_flag = !@flutter_local_engine.nil? ? "--local-engine=#{@flutter_local_engine}" : ''
        track_widget_creation_flag = @flutter_track_widget_creation_flag ? '--track-widget-creation' : ''

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

          system "cp -r -- \"#{@flutter_build_dir}/aot/App.framework\" \"#{@flutter_derived_dir}\""
        else
          # Build stub for all requested architectures.
          system "mkdir -p -- \"#{@flutter_derived_dir}/App.framework\""

          system "echo \"static const int Moo = 88;\" | xcrun clang -x c \
          -dynamiclib \
          -Xlinker -rpath -Xlinker '@executable_path/Frameworks' \
          -Xlinker -rpath -Xlinker '@loader_path/Frameworks' \
          -install_name '@rpath/App.framework/App' \
          -o \"#{@flutter_derived_dir}/App.framework/App\"
          "
          
        end

        # copy plist
        plistPath = File.join(@flutter_application_path, '.ios/Flutter/AppFrameworkInfo.plist')
        if !File.exist?(plistPath)
          plistPath = File.join(@flutter_application_path, 'ios/Flutter/AppFrameworkInfo.plist')
        end
        if File.exist?(plistPath)
            system "cp -- \"#{plistPath}\" \"#{@flutter_derived_dir}/App.framework/Info.plist\""
        end

        # build bundle
        precompilation_flag = ""
        if ENV["CURRENT_ARCH"] != "x86-64" && @flutter_build_mode != "debug"
            precompilation_flag = "--precompiled"
        end

        puts " ├─Assembling Flutter resources..."
        system "#{@flutter_root}/bin/flutter --suppress-analytics       \
        build bundle                                                    \
        --target-platform=ios                                           \
        --target=\"#{@flutter_target}\"                                 \
        --snapshot=\"#{@flutter_build_dir}/snapshot_blob.bin\"          \
        --#{@flutter_build_mode}                                        \
        --depfile=\"#{@flutter_build_dir}/snapshot_blob.bin.d\"         \
        --asset-dir=\"#{@flutter_derived_dir}/flutter_assets\"          \
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
