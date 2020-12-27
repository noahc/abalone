require "rails_helper"

RSpec.describe "Cohort Import" do
  let(:user) { create(:user) }
  let(:cohort_csv) { "tmp/cohort_import_test.csv" }

  let(:enclosure) { build(:enclosure) }
  let(:cohort_1) { build(:cohort, enclosure: enclosure) }
  let(:cohort_2) { build(:cohort, enclosure: enclosure) }

  let(:header) { CSV.open("public/samples/cohort.csv").readline }
  let(:row_1) { build_csv_row(cohort_1) }
  let(:row_2) { build_csv_row(cohort_2) }
  let(:rows) { [header, row_1] }

  def build_csv_row(cohort)
    [
      cohort.name,
      cohort.female_tag,
      cohort.male_tag,
      cohort.enclosure.name,
      cohort.enclosure.location.name
    ]
  end

  let!(:csv) do
    CSV.open(cohort_csv, "wb") do |csv|
      rows.each do |row|
        csv << row
      end
    end
  end

  before(:each) { sign_in user }

  after(:each) { File.delete(cohort_csv) }

  it "has headers" do
    expect(CSV.open(cohort_csv, "r").readline).to eq(
      %w[name female_tag male_tag enclosure location]
    )
  end

  it "creates cohorts from a CSV file" do
    visit new_cohort_import_path

    attach_file("cohort_csv", cohort_csv)

    click_on "Submit"

    expect(page).to have_current_path(cohorts_path)

    cohorts = Cohort.all
    expect(cohorts.count).to eql(1)
    expect(cohorts.first.organization_id).to eql(user.organization.id)
  end
end
