require "../../spec_helper"

# Examples taken from:
# https://relishapp.com/rspec/rspec-core/v/3-8/docs/hooks/before-and-after-hooks
# and modified to fit Spectator and Crystal.
Spectator.describe "`before` and `after` hooks" do
  context "Define `before_each` block" do
    class Thing
      def widgets
        @widgets ||= [] of Symbol # Must specify array element type.
      end
    end

    describe Thing do
      before_each do
        @thing = Thing.new
      end

      describe "initialize in before_each" do
        it "has 0 widgets" do
          widgets = @thing.as(Thing).widgets # Must cast since compile type is Thing?
          expect(widgets.size).to eq(0)      # Use size instead of count.
        end

        it "can accept new widgets" do
          widgets = @thing.as(Thing).widgets # Must cast since compile type is Thing?
          widgets << :foo
        end

        it "does not share state across examples" do
          widgets = @thing.as(Thing).widgets # Must cast since compile type is Thing?
          expect(widgets.size).to eq(0)      # Use size instead of count.
        end
      end
    end
  end

  context "Define `before_all` block in example group" do
    class Thing
      def widgets
        @widgets ||= [] of Symbol # Must specify array element type.
      end
    end

    describe Thing do
      # Moved before_all into the same example group.
      # Unlike Ruby, inherited class variables don't share the same value.
      # See: https://crystal-lang.org/reference/syntax_and_semantics/class_variables.html
      describe "initialized in before_all" do
        @@thing : Thing?

        before_all do
          @@thing = Thing.new # Must use class variables.
        end

        it "has 0 widgets" do
          widgets = @@thing.as(Thing).widgets # Must cast since compile type is Thing?
          expect(widgets.size).to eq(0)       # Use size instead of count.
        end

        it "can accept new widgets" do
          widgets = @@thing.as(Thing).widgets # Must cast since compile type is Thing?
          widgets << :foo
        end

        it "shares state across examples" do
          widgets = @@thing.as(Thing).widgets # Must cast since compile type is Thing?
          expect(widgets.size).to eq(1)       # Use size instead of count.
        end
      end
    end
  end

  context "Failure in `before_each` block" do
    # TODO
  end

  context "Failure in `after_each` block" do
    # TODO
  end

  context "Define `before` and `after` blocks in configuration" do
    # TODO
  end

  context "`before`/`after` blocks are run in order" do
    # Examples changed from using puts to appending to an array.
    describe "before and after callbacks" do
      @@order = [] of Symbol

      before_all do
        @@order << :before_all
      end

      before_each do
        @@order << :before_each
      end

      after_each do
        @@order << :after_each
      end

      after_all do
        @@order << :after_all
      end

      it "gets run in order" do
        expect(@@order).to_eventually eq(%i[before_all before_each after_each after_all])
      end
    end
  end
end
