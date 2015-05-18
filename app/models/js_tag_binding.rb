require 'digest'

class JsTagBinding < ActiveRecord::Base
  validates :account_id, :label, presence: true
  validates :checksum, :insales_js_tag_id, presence: true,
            if: -> { checksum.present? || insales_js_tag_id.present? }

  before_destroy :destroy_js_tag

  belongs_to :account

  def self.ensure_js_tag(account, label, text, test: false, force: false)
    binding =
      account.js_tag_bindings.where(label: label)
      .first_or_initialize

    binding.ensure_js_tag(text, test, force)
  end

  def self.ensure_js_include_tag(account, label, url, test: false, force: false)
    text = include_script(url)
    ensure_js_tag(account, label, text, test: test, force: force)
  end

  def self.remove_js_tag(account, label)
    account.js_tag_bindings.where(label: label).destroy_all
  end

  def js_tag
    return nil if insales_js_tag_id.blank?
    Rails.logger.info("Looking up JsTag #{insales_js_tag_id}...")
    account.configure_api
    InsalesApi::JsTag.find(insales_js_tag_id)
  end

  def ensure_js_tag(text, test = false, force = false)
    new_checksum = Digest::SHA256.new.hexdigest(text)

    self.checksum = new_checksum
    self.test_mode = test

    if checksum_changed? || test_mode_changed? || force
      make_js_tag(text)
    end

    insales_js_tag_id
  end

  def destroy_js_tag
    Rails.logger.info("Removing JsTag #{insales_js_tag_id}")
    js_tag.destroy if insales_js_tag_id.present?
  rescue ActiveResource::ResourceNotFound => ex
    Rails.logger.warn(
      "Failed to delete JsTag #{insales_js_tag_id}. Record not found."
    )
  end

  protected

  def self.include_script(url)
    rex = URI.regexp(%w(http https))
    fail 'Invalid URL' unless url.match(rex)

    <<-HERE
      // This includes script at #{url}
      var fileref = document.createElement('script');
      fileref.setAttribute("type","text/javascript");
      fileref.setAttribute("src", '#{url}');
      document.getElementsByTagName("head")[0].appendChild(fileref);
    HERE
  end

  def comment
    <<-HERE

      // JsTag by insales_app_core
      // Application: #{app_name}
      // Label: #{label}
      // Updated at: #{DateTime.now}
      #{test_mode ? "// Test mode" : ''}

    HERE
  end

  def test_script
    param_name = "enable_#{app_name}_#{label}_script=true"

    <<-HERE
      var regex = new RegExp("#{param_name}")
      var results = regex.exec(location.search);
      if(results === null) {
        return null;
      }
    HERE
  end

  def full_text(text)
    text = text.prepend(test_script) if test_mode
    text = text.prepend(comment)
    text
  end

  def app_name
    ENV['INSALES_API_KEY']
  end

  def make_js_tag(text)
    destroy_js_tag

    Rails.logger.info("Creating JsTag...")
    account.configure_api

    self.insales_js_tag_id = InsalesApi::JsTag.create(
      type: 'JsTag::TextTag',
      content: full_text(text)
    ).id

    self.save
  end
end
