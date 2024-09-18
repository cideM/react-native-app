
def try_setup_circle_ci()
  begin
    setup_circle_ci
  rescue => ex
    # this will fail if it is called twice, because the keychain is already created
    # see https://github.com/fastlane/fastlane/issues/13270
    UI.message("setup_circle_ci command failed. Continue anyway.")
  end
end


# This will update the build number.
# It will do nothing, if the version is nil or empty
def set_build_version(version, project)
  return if version.nil? || version.empty?

  increment_build_number(
    build_number: version,
    xcodeproj: project
  )
end


# This is a helper function wrapping environment variable access
# Call this instead of directly accessing environment variables.
# This function will return the variable if it is set,
# otherwise it will check if an .env file is loaded and load it
def env(name)
  return ENV[name] unless ENV[name].nil?
  if ENV['ENVIRONMENT_NAME'].nil?
    puts "No Environment defined via --env"
    env = prompt(text: "Environment (DE, US): ")
    Dotenv.load(".env.#{env}")
    puts "Loaded Environment #{ENV['ENVIRONMENT_NAME']}"
  end
  ENV[name]
end

def ensure_app_store_connect_environment_variables
  UI.message("Ensuring App Store Connect API Environment Variables. If you don't know them, you can find them in 1Password.")
  if ENV['APP_STORE_CONNECT_API_KEY_KEY_ID'].nil?
    ENV['APP_STORE_CONNECT_API_KEY_KEY_ID'] = prompt(text:"APP_STORE_CONNECT_API_KEY_KEY_ID: ")
  end

  if ENV['APP_STORE_CONNECT_API_KEY_ISSUER_ID'].nil?
    ENV['APP_STORE_CONNECT_API_KEY_ISSUER_ID'] = prompt(text:"APP_STORE_CONNECT_API_KEY_ISSUER_ID: ")
  end

  if ENV['APP_STORE_CONNECT_API_KEY_KEY'].nil?
    ENV['APP_STORE_CONNECT_API_KEY_KEY'] = prompt(text:"APP_STORE_CONNECT_API_KEY_KEY: ")
  end
  UI.message("Done.")
end

def git_info()
  info = GitInfo.new
  info.branch_name = git_branch()
  info.commits_count = Integer(sh("git rev-list --count origin/develop..HEAD").strip)
  if info.commits_count > 0
    info.notes = changelog_from_git_commits(
      commits_count: info.commits_count,
      pretty: "- %s",
      date_format: "short",
      match_lightweight_tag: false,
      merge_commit_filtering: "exclude_merges"
    )
  else
    info.notes = ""
  end
  info
end

def refresh_dsyms(bundle_identifier, gsp_path)
    upload_symbols_to_crashlytics(
      gsp_path: gsp_path,
      binary_path: crashlytics_binary_path
      )
    #clean_build_artifacts
end

class GitInfo
  @branch_name
  @commits_count
  @notes

  def initialize
    @branch_name = ""
    @commits_count = 0
    @notes = ""
  end
  def branch_name
    return @branch_name
  end
  def commits_count
    return @commits_count
  end
  def notes
    return @notes
  end

  def branch_name=(value)
    @branch_name = value
  end
  def commits_count=(value)
    @commits_count = value
  end
  def notes=(value)
    @notes = value;
  end
end

# Firebase symbol upload does not play well will SPM as of yet
# See here for more info: https://github.com/fastlane/fastlane/issues/17288#issuecomment-1174898650
def crashlytics_binary_path
  product_module_name = "Knowledge"
  dependencies_path = `xcodebuild -project Knowledge.xcodeproj -showBuildSettings -clonedSourcePackagesDirPath ../SourcePackages | grep IDEClonedSourcePackagesDirPathOverride | awk '{print $3}'`.strip()
  glob_path = "#{dependencies_path}/checkouts/firebase-ios-sdk/Crashlytics/upload-symbols"
  Dir.glob(glob_path)[0]
end
