require 'spec_helper'

describe 'insserv_override' do
  let(:title) { 'foo' }

  context 'with defaults' do
    it {
      is_expected.to contain_insserv_override('foo')

      is_expected.to contain_file('/etc/insserv/overrides/foo').
        with('ensure' => 'present',
             'owner'  => 'root',
             'group'  => 'root',
             'mode'   => '0644').
        that_notifies('Exec[insserv-overrides-foo]')

      is_expected.to contain_exec('insserv-overrides-foo').
        with('command'     => 'insserv -r foo ; insserv -d foo',
             'cwd'         => '/',
             'refreshonly' => true)

      is_expected.to contain_file('/etc/insserv/overrides/foo').
        with_content(/^# Provides: +foo$/)
    }
  end

  context 'with ensure => absent' do
    let(:params) do
      { ensure: 'absent' }
    end

    it {
      is_expected.to contain_insserv_override('foo')

      is_expected.to contain_file('/etc/insserv/overrides/foo').
        with('ensure' => 'absent').
        that_notifies('Exec[insserv-overrides-foo]')

      is_expected.to contain_exec('insserv-overrides-foo').
        with('command'     => 'insserv -r foo ; insserv -d foo',
             'cwd'         => '/',
             'refreshonly' => true)
    }
  end

  context 'with resource title quux' do
    let(:title) { 'quux' }

    it {
      is_expected.to contain_insserv_override('quux')

      is_expected.to contain_file('/etc/insserv/overrides/quux').
        with('ensure' => 'present',
             'owner'  => 'root',
             'group'  => 'root',
             'mode'   => '0644').
        that_notifies('Exec[insserv-overrides-quux]')

      is_expected.to contain_exec('insserv-overrides-quux').
        with('command'     => 'insserv -r quux ; insserv -d quux',
             'cwd'         => '/',
             'refreshonly' => true)

      is_expected.to contain_file('/etc/insserv/overrides/quux').
        with_content(/^# Provides: +quux$/)
    }
  end

  context 'with provides => bar' do
    let(:params) do
      { provides: 'bar' }
    end

    it {
      is_expected.to contain_file('/etc/insserv/overrides/foo').
        with_content(/^# Provides: +bar$/)
    }
  end

  context 'with provides => [bar, baz]' do
    let(:params) do
      { provides: [ 'bar', 'baz' ] }
    end

    it {
      is_expected.to contain_file('/etc/insserv/overrides/foo').
        with_content(/^# Provides: +bar baz$/)
    }
  end

  context 'with required_start => bar' do
    let(:params) do
      { required_start: 'bar' }
    end

    it {
      is_expected.to contain_file('/etc/insserv/overrides/foo').
        with_content(/^# Required-Start: +bar$/)
    }
  end

  context 'with required_stop => bar' do
    let(:params) do
      { required_stop: 'bar' }
    end

    it {
      is_expected.to contain_file('/etc/insserv/overrides/foo').
        with_content(/^# Required-Stop: +bar$/)
    }
  end

  context 'with is_expected.to_start => bar' do
    let(:params) do
      { :is_expected.to_start => 'bar' }
    end

    it {
      is_expected.to contain_file('/etc/insserv/overrides/foo').
        with_content(/^# Should-Start: +bar$/)
    }
  end

  context 'with is_expected.to_stop => bar' do
    let(:params) do
      { :is_expected.to_stop => 'bar' }
    end

    it {
      is_expected.to contain_file('/etc/insserv/overrides/foo').
        with_content(/^# Should-Stop: +bar$/)
    }
  end

  context 'with x_start_before => bar' do
    let(:params) do
      { x_start_before: 'bar' }
    end

    it {
      is_expected.to contain_file('/etc/insserv/overrides/foo').
        with_content(/^# X-Start-Before: +bar$/)
    }
  end

  context 'with x_stop_after => bar' do
    let(:params) do
      { x_stop_after: 'bar' }
    end

    it {
      is_expected.to contain_file('/etc/insserv/overrides/foo').
        with_content(/^# X-Stop-After: +bar$/)
    }
  end

  context 'with default_start => [S]' do
    let(:params) do
      { default_start: [ 'S' ] }
    end

    it {
      is_expected.to contain_file('/etc/insserv/overrides/foo').
        with_content(/^# Default-Start: +S$/)
    }
  end


  context 'with default_start => [1, 3, 5]' do
    let(:params) do
      { default_start: ['1', '3', '5'] }
    end

    it {
      is_expected.to contain_file('/etc/insserv/overrides/foo').
        with_content(/^# Default-Start: +1 3 5$/)
    }
  end

  context 'with default_stop => [2, 4, 6]' do
    let(:params) do
      { default_stop: ['2', '4', '6'] }
    end

    it {
      is_expected.to contain_file('/etc/insserv/overrides/foo').
        with_content(/^# Default-Stop: +2 4 6$/)
    }
  end

  context 'with x_interactive => true' do
    let(:params) do
      { x_interactive: true }
    end

    it {
      is_expected.to contain_file('/etc/insserv/overrides/foo').
        with_content(/^# X-Interactive: +true$/)
    }
  end

  context 'with x_interactive => false' do
    let(:params) do
      { x_interactive: false }
    end

    it {
      is_expected.to contain_file('/etc/insserv/overrides/foo').
        without_content(/^# X-Interactive:/)
    }
  end

  context 'with x_interactive => foo' do
    let(:params) do
      { x_interactive: 'foo' }
    end

    it {
      expect { is_expected.to compile }.to raise_error(/not a boolean/)
    }
  end

  context 'with short_description => "foo bar baz"' do
    let(:params) do
      { short_description: 'foo bar baz' }
    end

    it {
      is_expected.to contain_file('/etc/insserv/overrides/foo').
        with_content(/^# Short-Description: +foo bar baz$/)
    }
  end

  context 'with required_start => ""' do
    let(:params) do
      { required_start: '' }
    end

    it {
      is_expected.to contain_file('/etc/insserv/overrides/foo').
        with_content(/^# Required-Start: +$/)
    }
  end

  context 'with required_start => []' do
    let(:params) do
      { required_start: [] }
    end

    it {
      is_expected.to contain_file('/etc/insserv/overrides/foo').
        with_content(/^# Required-Start: +$/)
    }
  end

  context 'with conflicting runlevels' do
    let(:params) do
      { default_start: [ '1', '5'], default_stop: [ '1', '2' ] }
    end

    it {
      expect { is_expected.to compile }.to raise_error(/runlevels.*must be distinct/)
    }
  end
end
