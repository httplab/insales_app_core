require 'digest'

class JsTagBinding < ActiveRecord::Base
  validates :account_id, :label, presence: true
  validates :checksum, :insales_js_tag_id, presence: true,
            if: -> { checksum.present? || insales_js_tag_id.present? }

  before_destroy :destroy_js_tag

  belongs_to :account

  def self.ensure_js_tag(account, label, text, force = false)
    binding =
      account.js_tag_bindings.where(label: label)
      .first_or_initialize

    binding.ensure_js_tag(text, force = false)
  end

  def self.ensure_js_include_tag(account, label, url, force = false)
    text = include_script(url)
    ensure_js_tag(account, label, text, force)
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

  def ensure_js_tag(text, force = false)
    new_checksum = Digest::SHA256.new.hexdigest(text)

    if (checksum != new_checksum) || force
      make_js_tag(text, new_checksum)
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
      // Application: #{ENV['INSALES_API_KEY']}
      // Label: #{label}
      // Updated at: #{DateTime.now}

    HERE
  end

  def make_js_tag(text, new_checksum)
    destroy_js_tag
    text = text.prepend(comment)
    Rails.logger.info("Creating JsTag...")
    account.configure_api

    js_tag_id = InsalesApi::JsTag.create(
      type: 'JsTag::TextTag',
      content: text
    ).id

    self.checksum = new_checksum
    self.insales_js_tag_id = js_tag_id
    self.save
  end
end
