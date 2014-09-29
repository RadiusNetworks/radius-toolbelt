RSpec.describe 'The `radius` CLI:', type: :feature do

  def bin_radius
    @_bin_radius ||= if File.exist?('sbin/radius')
                       'sbin/radius'
                     else
                       'bundle exec radius'
                     end
  end

  it 'running `radius` is successful' do
    expect(system bin_radius).to be true
  end

end
