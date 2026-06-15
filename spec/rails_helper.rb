require "spec_helper"
ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
abort("The Rails environment is running in production mode!") if Rails.env.production?
require "rspec/rails"

Dir[Rails.root.join("spec", "support", "**", "*.rb")].sort.each { |f| require f }

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  config.fixture_paths = [ Rails.root.join("spec/fixtures") ]
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  config.include FactoryBot::Syntax::Methods
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include ActiveJob::TestHelper

  config.before(:suite) do
    ActiveJob::Base.queue_adapter = :test
  end

  # Stub background jobs and ActionCable broadcasts in model/request specs
  # so tests stay isolated — jobs are tested directly in spec/jobs
  config.before(:each, type: :model) do
    allow(NotificationJob).to receive(:perform_later)
    allow(ActionCable.server).to receive(:broadcast)
  end

  config.before(:each, type: :request) do
    allow(NotificationJob).to receive(:perform_later)
    allow(ActionCable.server).to receive(:broadcast)
  end
end
