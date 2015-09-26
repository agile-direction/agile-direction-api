require 'i18n/tasks'

RSpec.describe 'I18n' do
  let(:i18n) { I18n::Tasks::BaseTask.new }
  let(:missing_keys) { i18n.missing_keys }
  let(:unused_keys) { i18n.unused_keys }

  it 'does not have missing keys' do
    pp missing_keys unless missing_keys.empty?
    expect(missing_keys).to be_empty, "Missing i18n keys: #{missing_keys}"
  end

  it 'does not have unused keys' do
    pp unused_keys unless unused_keys.empty?
    expect(unused_keys).to be_empty, "Unused i18n keys: #{unused_keys}"
  end
end
