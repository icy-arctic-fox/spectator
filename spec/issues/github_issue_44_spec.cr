require "../spec_helper"

Spectator.describe "GitHub Issue #44" do
  inject_mock Process do
    # Instance variable that can be nil, provide a default.
    @process_info = Crystal::System::Process.new(0)
  end

  let(command) { "ls -l" }
  let(exception) { File::NotFoundError.new("File not found", file: "test.file") }

  context "with positional arguments" do
    before_each do
      pipe = Process::Redirect::Pipe
      expect(Process).to receive(:run).with(command, nil, nil, false, true, pipe, pipe, pipe, nil).and_raise(exception)
    end

    it "must stub Process.run" do
      expect do
        Process.run(command, shell: true, output: :pipe) do |_process|
        end
      end.to raise_error(File::NotFoundError, "File not found")
    end
  end

  # Original issue uses keyword arguments in place of positional arguments.
  context "keyword arguments in place of positional arguments" do
    before_each do
      pipe = Process::Redirect::Pipe
      expect(Process).to receive(:run).with(command, shell: true, output: pipe).and_raise(exception)
    end

    it "must stub Process.run" do
      expect do
        Process.run(command, shell: true, output: :pipe) do |_process|
        end
      end.to raise_error(File::NotFoundError, "File not found")
    end
  end
end
