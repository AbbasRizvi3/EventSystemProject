require "simplecov"
SimpleCov.start "rails" do
  coverage_dir "/tmp/coverage"
  at_exit do
    result = SimpleCov.result
    puts "\nCoverage: #{result.covered_percent.round(2)}%\n\n"
    puts "Files under 90%:"
    result.files.sort_by(&:covered_percent).each do |f|
      next if f.covered_percent >= 90
      puts "  #{f.covered_percent.round(1)}%  #{f.filename.sub(Dir.pwd + '/', '')}"
    end
  end
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
end
