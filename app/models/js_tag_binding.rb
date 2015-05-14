require 'digest'

class JsTagBinding < ActiveRecord::Base
  validates :account_id, :label, :tag_type, presence: true
  validates :checksum, :insales_js_tag_id, presence: true,
            if: -> { checksum.present? || insales_js_tag_id.present? }

  before_destroy :destroy_js_tag

  belongs_to :account

  enum tag_type: { file_tag: 0, text_tag: 1 }

  def self.ensure_js_tag(account, label, tag_type, text, force = false)
    binding =
      account.js_tag_bindings.where(label: label)
      .first_or_initialize(tag_type: tag_type)

    binding.ensure_js_tag(tag_type, text, force = false)
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

  def ensure_js_tag(tag_type, text, force = false)
    new_checksum = Digest::SHA256.new.hexdigest(text)

    if (checksum != new_checksum) || (tag_type != self.tag_type) || force
      make_js_tag(tag_type, text, new_checksum)
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

  def comment
    <<-HERE

      // JsTag by insales_app_core
      // Application: #{ENV['INSALES_API_KEY']}
      // Label: #{label}
      // Updated at: #{DateTime.now}

    HERE
  end

  def make_js_tag(tag_type, text, new_checksum)
    destroy_js_tag
    self.tag_type = tag_type
    text = text.prepend(comment) if tag_type == 'text_tag'

    Rails.logger.info("Creating JsTag...")
    js_tag_id = InsalesApi::JsTag.create(
      type: insales_js_tag_type,
      content: text
    ).id

    self.checksum = new_checksum
    self.insales_js_tag_id = js_tag_id
    self.save
  end

  def insales_js_tag_type
    case tag_type
    when 'file_tag'
      'JsTag::FileTag'
    when 'text_tag'
      'JsTag::TextTag'
    end
  end
end
