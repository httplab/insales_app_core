module InsalesAppCore
  module ControllerExtensions
    module Styx
      extend ActiveSupport::Concern

      included do
        include ::Styx::Initializer
        # TODO: Возможно стоит включить в будущем, или сделать опциональным
        # include ::Styx::Forms
      end
    end
  end
end

