module InsalesAppCore::TestHelpers::Controller
  def login_account(account)
    allow_any_instance_of(ApplicationController).to receive(:authenticate).and_return(true)
    allow_any_instance_of(ApplicationController).to receive(:configure_api).and_return(true)
    allow_any_instance_of(ApplicationController).to receive(:current_account).and_return(account)
  end
end
