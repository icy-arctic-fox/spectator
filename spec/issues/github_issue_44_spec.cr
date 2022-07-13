require "../spec_helper"

Spectator.describe Test do
  inject_mock Process do
    # Instance variable that can be nil, provide a default.
    @process_info = Crystal::System::Process.new(0)
  end

  let(command) { "ls -l" }
  let(exception) { File::NotFoundError.new("File not found", file: "test.file") }

  before_each do
    expect(Process).to receive(:run).with(command, shell: true, output: :pipe).and_raise(exception)
  end

  skip "must stub Process.run", skip: "Method mock not applied" do
    Process.run(command, shell: true, output: :pipe) do |process|
    end
  end
end
