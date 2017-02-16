require 'spec_helper'

describe 'server' do
  context 'packages' do
    let(:params) {
      { :packages => ['git'] }
    }

    it { is_expected.to contain_package('git') }
  end

  context 'packages with params' do
    let(:params) {
      { :packages => {
        'git' => { 'ensure' => 'latest' }
      } }
    }

    it { is_expected.to contain_package('git').with(
      'ensure' => 'latest'
    ) }
  end

  context 'cron jobs' do
    let(:params) {
      { :cron => { 'install' => true, 'jobs' => {
        'test' => {
          'command' => '/bin/true',
          'hour'    => 0,
          'minute'  => 0,
        }
      } } }
    }

    it { is_expected.to contain_cron('test').with(
      'command' => '/bin/true',
      'hour'    => 0,
      'minute'  => 0,
    ) }
  end

  context 'acls' do
    let(:params) {
      {
        :acls         => { '/var/www' => ['u:1000:rwX'], '/root' => [] },
        :default_acls => ['u:root:rwX']
      }
    }

    it { is_expected.to contain_fooacl__conf('server_acl_/var/www').with(
      'target'      => '/var/www',
      'permissions' => ['u:root:rwX', 'u:1000:rwX'],
    ) }

    it { is_expected.to contain_fooacl__conf('server_acl_/root').with(
      'target'      => '/root',
      'permissions' => ['u:root:rwX'],
    ) }
  end

  context 'classes' do
    let(:params) {
      { :classes => ['fooacl'] }
    }

    it { is_expected.to contain_class('fooacl') }
  end

  context 'resources' do
    let(:params) {
      { :resources => {
        'fooacl::conf' => { 'root' => { 'target' => '/root', 'permissions' => ['u:root:rwX'] } }
      } }
    }

    it { is_expected.to contain_fooacl__conf('root').with(
      'target'      => '/root',
      'permissions' => ['u:root:rwX'],
    ) }
  end
end
