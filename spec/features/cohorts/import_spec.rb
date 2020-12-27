require 'rails_helper'

RSpec.describe "Cohort Import" do
  let(:user) { create(:user) }

  before { sign_in user }

  it "creates cohorts from a CSV file" do
    create(:facility, name: 'Aquarium of the Pacific', code: 'AOP', organization_id: user.organization.id)

    visit new_cohort_import_path

    attach_file('cohort_csv', "#{Rails.root}/spec/fixtures/cohorts.csv")

    click_on 'Submit'

    expect(page).to have_current_path(cohorts_path)

    cohorts = Cohort.all
    expect(cohorts.count).to eql(1)
    expect(cohorts.first.organization_id).to eql(user.organization.id)
  end
end
