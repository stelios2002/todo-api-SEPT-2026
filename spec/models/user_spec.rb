require "rails_helper"

RSpec.describe User, type: :model do
  it { should have_many(:todos).dependent(:destroy) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:email) }

  it "κρυπτογραφεί το password" do
    user = create(:user, password: "password123")
    expect(user.password_digest).not_to eq("password123")
    expect(user.authenticate("password123")).to be_truthy
    expect(user.authenticate("wrong")).to be false
  end
end