require File.join(File.dirname(__FILE__), '..', 'lib', 'parity')

describe Parity do
  context ".run" do
    it "delegates to Parity:Environment" do
      environment = double("environment", run: nil)
      Parity::Environment.stub(new: environment)

      Parity.run(:environment, :arguments)

      expect(Parity::Environment).to have_received(:new).with(:environment)
      expect(environment).to have_received(:run).with(:arguments)
    end

    context "error handling" do
      before { $stderr.stub(:puts) }

      it "prints errors and exits" do
        error = RuntimeError.new("boom")
        exit_occurred = false
        Parity::Environment.stub(:new).and_raise(error)

        begin Parity.run('', '')
        rescue SystemExit
          exit_occurred = true
        end

        expect($stderr).to have_received(:puts).with("Error: (RuntimeError) boom")
        expect(exit_occurred).to be_true
      end

      it "includes usage for ArgumentErrors" do
        error = ArgumentError.new("invalid")
        Parity::Environment.stub(:new).and_raise(error)
        Parity::Usage.stub(new: :usage)

        begin Parity.run('', '')
        rescue SystemExit
        end

        expect($stderr).to have_received(:puts).with("Error: (ArgumentError) invalid")
        expect($stderr).to have_received(:puts).with(:usage)
      end
    end
  end
end
