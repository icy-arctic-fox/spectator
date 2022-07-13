require "../spec_helper"

Spectator.describe Spectator::SystemExit do
  it "is raised when an attempt is made to exit the application" do
    expect { exit }.to raise_error(described_class)
  end

  it "has the status code passed to an exit call" do
    exit 5
  rescue error : Spectator::SystemExit
    expect(error.status).to eq(5)
  end
end
