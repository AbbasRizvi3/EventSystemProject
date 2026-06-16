require "rails_helper"

RSpec.describe Event, type: :model do
  subject { build(:event) }

  describe "associations" do
    it { should belong_to(:user) }
    it { should have_many(:registrations).dependent(:destroy) }
    it { should have_many(:attendees).through(:registrations).source(:user) }
    it { should have_many(:wait_list_entries).dependent(:destroy) }
    it { should have_many(:waitlisted_users).through(:wait_list_entries).source(:user) }
  end

  describe "validations" do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:location) }
    it { should validate_presence_of(:start_time) }
    it { should validate_presence_of(:end_time) }
    it { should validate_presence_of(:capacity) }
    it { should validate_presence_of(:status) }

    it { should validate_length_of(:title).is_at_least(3).is_at_most(50)
                                          .with_short_message("must be at least 3 characters")
                                          .with_long_message("must be at most 50 characters") }

    it { should validate_length_of(:location).is_at_least(2).is_at_most(50)
                                             .with_short_message("must be at least 2 characters")
                                             .with_long_message("must be at most 50 characters") }

    it { should validate_length_of(:description).is_at_most(200)
                                                .with_long_message("must be at most 200 characters") }

    it "is valid with all required attributes" do
      expect(build(:event)).to be_valid
    end

    it "is invalid with a duplicate title (case-insensitive)" do
      create(:event, title: "Ruby Conference")
      duplicate = build(:event, title: "ruby conference")
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:title]).to include("has already been taken")
    end

    it "is invalid with capacity of 0" do
      expect(build(:event, capacity: 0)).not_to be_valid
    end

    it "is invalid with capacity exceeding 10,000" do
      expect(build(:event, capacity: 10_001)).not_to be_valid
    end

    it "is valid with capacity of 10,000" do
      expect(build(:event, capacity: 10_000)).to be_valid
    end

    it "is invalid with a non-integer capacity" do
      expect(build(:event, capacity: 5.5)).not_to be_valid
    end

    it "is invalid with description longer than 200 characters" do
      expect(build(:event, description: "A" * 201)).not_to be_valid
    end
  end

  describe "end_time_after_start_time validation" do
    it "is invalid when end_time is before start_time" do
      event = build(:event, start_time: 2.days.from_now, end_time: 1.day.from_now)
      expect(event).not_to be_valid
      expect(event.errors[:end_time]).to include("must be after start time")
    end

    it "is invalid when end_time equals start_time" do
      time = 1.day.from_now
      event = build(:event, start_time: time, end_time: time)
      expect(event).not_to be_valid
    end

    it "is valid when end_time is after start_time" do
      expect(build(:event)).to be_valid
    end
  end

  describe "status enum" do
    it "defaults to active" do
      expect(build(:event).status).to eq("active")
    end

    it "can be set to cancelled" do
      expect(create(:event, :cancelled)).to be_cancelled
    end

    it "recognises active? predicate" do
      expect(create(:event)).to be_active
    end
  end
end
