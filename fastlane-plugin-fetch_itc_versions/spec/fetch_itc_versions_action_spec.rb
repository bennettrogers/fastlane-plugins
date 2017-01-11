describe Fastlane::Actions::FetchItcVersionsAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The fetch_itc_versions plugin is working!")

      Fastlane::Actions::FetchItcVersionsAction.run(nil)
    end
  end
end
