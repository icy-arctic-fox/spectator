require "../spec_helper"

Spectator.describe "GitHub Issue #55" do
  GROUP_NAME = "CallCenter"

  let(name) { "TimeTravel" }
  let(source) { "my.time.travel.experiment" }

  class Analytics(T)
    property start_time = Time.local
    property end_time = Time.local

    def initialize(@brain_talker : T)
    end

    def instrument(*, name, source, &)
      @brain_talker.send(payload: {
        :group  => GROUP_NAME,
        :name   => name,
        :source => source,
        :start  => start_time,
        :end    => end_time,
      }, action: "analytics")
    end
  end

  double(:brain_talker, send: nil)

  let(brain_talker) { double(:brain_talker) }
  let(analytics) { Analytics.new(brain_talker) }

  it "tracks the time it takes to run the block" do
    analytics.start_time = expected_start_time = Time.local
    expected_end_time = expected_start_time + 10.seconds
    analytics.end_time = expected_end_time + 0.5.seconds # Offset to ensure non-exact match.

    analytics.instrument(name: name, source: source) do
    end

    expect(brain_talker).to have_received(:send).with(payload: {
      :group  => GROUP_NAME,
      :name   => name,
      :source => source,
      :start  => expected_start_time,
      :end    => be_within(1.second).of(expected_end_time),
    }, action: "analytics")
  end
end
