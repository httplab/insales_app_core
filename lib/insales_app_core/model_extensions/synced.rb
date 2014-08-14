module InsalesAppCore::ModelExtensions::Synced
  extend ActiveSupport::Concern

  module ClassMethods
    # TODO: Вынести в настройки(параметры, константы) дефолтовый размер страницы
    def get_all(page_size = nil, addl_params = {})
      page = 1
      while true do
        params = { page: page, per_page: page_size }.merge(addl_params)
        params.delete_if { |k,v| v.nil? }
        # TODO: Вынести в настройки(параметры, константы) дефолтовый параметр wait_retry
        page_result = InsalesApi.wait_retry(10) { insales_class.find(:all, params: params) }

        # https://github.com/rails/activeresource/commit/c665bf3c7ccc834017a2168ee3c8a68a622b70e6
        # Пока это не попадет в релиз, придется использовать to_a
        return if page_result.to_a.empty?

        page_result.each { |obj| yield obj } if block_given?
        page += 1
      end
    end
  end
end
