#
# Cookbook Name:: iis-lb
# Spec:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

require 'spec_helper'

describe 'iis-lb::_arr' do
  context 'When all attributes are default, on Windows 2012R2' do
    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'windows', version: '2012R2')
      runner.converge(described_recipe)
    end

    it 'adds a webpi_product resource, with the name ARRv3_0 and EULA to the collection' do
      expect(chef_run).to install_webpi_product('ARRv3_0')
      expect(chef_run.webpi_product('ARRv3_0').accept_eula).to eq(true)
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end
  end
end
