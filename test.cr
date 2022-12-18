require "./src/spectator"

module Thing
  def self.original_method
    :original
  end

  def self.default_method
    :original
  end

  def self.stubbed_method(_value = 42)
    :original
  end

  macro finished
    def self.debug
      {% begin %}puts "Methods: ", {{@type.methods.map &.name.stringify}} of String{% end %}
      {% begin %}puts "Class Methods: ", {{@type.class.methods.map &.name.stringify}} of String{% end %}
    end
  end
end

Thing.debug

# Spectator::Mock.define_subtype(:module, Thing, MockThing, default_method: :default) do
#   stub def stubbed_method(_value = 42)
#     :stubbed
#   end
# end

# Spectator.describe "Mock modules" do
#   let(mock) { MockThing }

#   after { mock._spectator_clear_stubs }

#   it "overrides an existing method" do
#     stub = Spectator::ValueStub.new(:original_method, :override)
#     expect { mock._spectator_define_stub(stub) }.to change { mock.original_method }.from(:original).to(:override)
#   end

#   it "doesn't affect other methods" do
#     stub = Spectator::ValueStub.new(:stubbed_method, :override)
#     expect { mock._spectator_define_stub(stub) }.to_not change { mock.original_method }
#   end

#   it "replaces an existing default stub" do
#     stub = Spectator::ValueStub.new(:default_method, :override)
#     expect { mock._spectator_define_stub(stub) }.to change { mock.default_method }.to(:override)
#   end

#   it "replaces an existing stubbed method" do
#     stub = Spectator::ValueStub.new(:stubbed_method, :override)
#     expect { mock._spectator_define_stub(stub) }.to change { mock.stubbed_method }.to(:override)
#   end

#   def restricted(thing : Thing.class)
#     thing.default_method
#   end

#   describe "._spectator_clear_stubs" do
#     before do
#       stub = Spectator::ValueStub.new(:original_method, :override)
#       mock._spectator_define_stub(stub)
#     end

#     it "removes previously defined stubs" do
#       expect { mock._spectator_clear_stubs }.to change { mock.original_method }.from(:override).to(:original)
#     end
#   end

#   describe "._spectator_calls" do
#     before { mock._spectator_clear_calls }

#     # Retrieves symbolic names of methods called on a mock.
#     def called_method_names(mock)
#       mock._spectator_calls.map(&.method)
#     end

#     it "stores calls to original methods" do
#       expect { mock.original_method }.to change { called_method_names(mock) }.from(%i[]).to(%i[original_method])
#     end

#     it "stores calls to default methods" do
#       expect { mock.default_method }.to change { called_method_names(mock) }.from(%i[]).to(%i[default_method])
#     end

#     it "stores calls to stubbed methods" do
#       expect { mock.stubbed_method }.to change { called_method_names(mock) }.from(%i[]).to(%i[stubbed_method])
#     end

#     it "stores multiple calls to the same stub" do
#       mock.stubbed_method
#       expect { mock.stubbed_method }.to change { called_method_names(mock) }.from(%i[stubbed_method]).to(%i[stubbed_method stubbed_method])
#     end

#     it "stores arguments for a call" do
#       mock.stubbed_method(5)
#       args = Spectator::Arguments.capture(5)
#       call = mock._spectator_calls.first
#       expect(call.arguments).to eq(args)
#     end
#   end
# end
