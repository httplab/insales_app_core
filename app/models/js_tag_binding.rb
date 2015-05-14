require 'digest'

class JsTagBinding < ActiveRecord::Base
  validates :account_id, :label, :tag_type, presence: true
  validates :checksum, :insales_js_tag_id, presence: true,
            if: -> { checksum.present? || insales_js_tag_id.present? }

  before_destroy :destroy_js_tag

  belongs_to :account

  enum tag_type: { file_tag: 0, text_tag: 1 }

  def self.ensure_js_tag(account_or_id, label, type, text)
    account = find_account(account_or_id)
    binding =
      account.js_tag_bindings.where(label: label)
      .first_or_initialize(tag_type: type)

    binding.ensure_js_tag(type, text)
  end

  def self.remove_js_tag(account_or_id, label)
    account = find_account(account_or_id)
    account.js_tag_bindings.where(label: label).destroy_all
  end

  def js_tag
    return nil if insales_js_tag_id.blank?
    Rails.logger.info("Looking up JsTag #{insales_js_tag_id}...")
    InsalesApi::JsTag.find(insales_js_tag_id)
  end

  def make_js_tag(type, text, new_checksum)
    destroy_js_tag

    self.tag_type = type

    Rails.logger.info("Creating JsTag...")
    js_tag_id = InsalesApi::JsTag.create(
      type: insales_js_tag_type,
      content: text
    ).id

    self.checksum = new_checksum
    self.insales_js_tag_id = js_tag_id
    self.save
  end

  def ensure_js_tag(type, text)
    new_checksum = self.class.calculate_checksum(text)

    if (checksum != new_checksum) || (type != tag_type)
      make_js_tag(tag_type, text, new_checksum)
    end

    insales_js_tag_id
  end

  def destroy_js_tag
    account.configure_api
    Rails.logger.info("Removing JsTag #{insales_js_tag_id}")
    js_tag.destroy if insales_js_tag_id.present?
  rescue ActiveResource::ResourceNotFound => ex
    Rails.logger.warn("Failed to delete JsTag #{insales_js_tag_id}. Record not found.")
  end

  protected

  def self.find_account(account_or_id)
    account_or_id.is_a?(Account) ? account_or_id : Account.find(account_or_id)
  end

  def self.calculate_checksum(text)
    @sha256 ||= Digest::SHA256.new
    @sha256.hexdigest(text)
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
