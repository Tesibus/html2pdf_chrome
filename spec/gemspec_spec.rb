# frozen_string_literal: true

require "fileutils"
require "open3"
require "rbconfig"
require "tmpdir"

RSpec.describe "html2pdf_chrome.gemspec" do
  let(:gem_root) { File.expand_path("..", __dir__) }
  let(:packaged_files) do
    %w[
      lib/html2pdf_chrome.rb
      lib/html2pdf_chrome/chromedriver.rb
      lib/html2pdf_chrome/html_converter.rb
      lib/html2pdf_chrome/version.rb
      sig/html2pdf_chrome.rbs
      LICENSE.txt
      README.md
    ]
  end

  # Keeps the child process from loading this checkout's bundle (and with it
  # this checkout's gemspec) before it loads the copy.
  let(:without_bundler) { { "RUBYOPT" => nil, "BUNDLE_GEMFILE" => nil, "BUNDLER_SETUP" => nil } }

  # Loads the gemspec in a separate Ruby process, from a copy of the gem that
  # is not a git checkout, and returns the files it lists. `extra_files` are
  # created in the copy first.
  def files_listed_outside_a_checkout(env = {}, extra_files: [])
    Dir.mktmpdir do |dir|
      sources = %w[html2pdf_chrome.gemspec lib sig LICENSE.txt README.md]
      FileUtils.cp_r(sources.map { |source| File.join(gem_root, source) }, dir)
      extra_files.each do |extra_file|
        FileUtils.mkdir_p(File.join(dir, File.dirname(extra_file)))
        File.write(File.join(dir, extra_file), "")
      end

      listed, errors, status = Open3.capture3(
        without_bundler.merge(env),
        RbConfig.ruby, "-e", "puts Gem::Specification.load(ARGV[0]).files",
        File.join(dir, "html2pdf_chrome.gemspec")
      )
      raise "the gemspec did not load: #{errors}" unless status.success?

      listed.split("\n")
    end
  end

  it "lists the gem's files, and nothing else, when the directory is not a git checkout" do
    expect(files_listed_outside_a_checkout).to match_array(packaged_files)
  end

  it "lists every file under lib and exe, and no development file" do
    listed = files_listed_outside_a_checkout(
      extra_files: %w[lib/html2pdf_chrome/template.html exe/html2pdf spec/extra_spec.rb Gemfile]
    )

    expect(listed).to match_array(packaged_files + %w[lib/html2pdf_chrome/template.html exe/html2pdf])
  end

  it "lists the gem's files when git is not installed" do
    Dir.mktmpdir do |empty_path|
      expect(files_listed_outside_a_checkout({ "PATH" => empty_path })).to match_array(packaged_files)
    end
  end
end
