require 'spec_helper'

describe AccountSettingsController do
  let!(:account) { FactoryGirl.create :account }

  context 'GET edit' do
    it 'returns success if account logged' do
      login_account(account)
      get :edit
      expect(response.status).to eq 200
    end

    it 'returns 302 if account isnt logged' do
      get :edit
      expect(response.status).to eq 302
    end
  end
end
