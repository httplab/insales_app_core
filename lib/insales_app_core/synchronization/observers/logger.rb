require 'colorize'

module InsalesAppCore::Synchronization::Observers
  class Logger < Struct.new(:send_to_stdout)
    ACTION_NAMES = {
      ::InsalesAppCore::Synchronization::Synchronizer::ENTITY_CREATED => 'CREATED',
      ::InsalesAppCore::Synchronization::Synchronizer::ENTITY_MODIFIED => 'MODIFIED',
      ::InsalesAppCore::Synchronization::Synchronizer::ENTITY_DELETED => 'DELETED',
      ::InsalesAppCore::Synchronization::Synchronizer::ENTITY_INTACT => 'INTACT',
      ::InsalesAppCore::Synchronization::Synchronizer::WILL_WAIT_FOR => 'WILL WAIT FOR',
      ::InsalesAppCore::Synchronization::Synchronizer::STAGE => 'STAGE',
      ::InsalesAppCore::Synchronization::Synchronizer::END_SYNC => 'END SYNC',
      ::InsalesAppCore::Synchronization::Synchronizer::REQUEST => 'REQUEST',
      ::InsalesAppCore::Synchronization::Synchronizer::BEGIN_SYNC => 'BEGIN SYNC'
    }

    ACTION_COLORS = {
      ::InsalesAppCore::Synchronization::Synchronizer::ENTITY_CREATED => 'green',
      ::InsalesAppCore::Synchronization::Synchronizer::ENTITY_MODIFIED => 'yellow',
      ::InsalesAppCore::Synchronization::Synchronizer::ENTITY_DELETED => 'red',
      ::InsalesAppCore::Synchronization::Synchronizer::WILL_WAIT_FOR => 'red',
      ::InsalesAppCore::Synchronization::Synchronizer::REQUEST => 'blue'
    }

    def update(type, *args)
      account_id = args.last
      entity = args[0]

      current_account_tag = "Account##{account_id}"
      current_action_tag = action_to_string(type)

      self.class.logger.tagged(current_account_tag, current_action_tag) do
        self.class.logger.info entity_to_string(entity)
      end

      if send_to_stdout
        self.class.stdout_logger.tagged(current_account_tag, current_action_tag) do
          self.class.stdout_logger.info entity_to_string(entity).send(action_to_color(type))
        end
      end
    end

    def self.log_file_path
      Rails.root.join('log', "synchronization_#{Rails.env}.log")
    end

    def self.logger
      unless @logger
        l = ::Logger.new(log_file_path)
        l.formatter = ::Logger::Formatter.new
        @logger = ActiveSupport::TaggedLogging.new(l)
      end
      @logger
    end

    def self.stdout_logger
      unless @stdout_logger
        l = ::Logger.new(STDOUT)
        l.formatter = ::Logger::Formatter.new
        @stdout_logger = ActiveSupport::TaggedLogging.new(l)
      end
      @stdout_logger
    end

    private

    def entity_to_string(entity)
      if entity.respond_to? :account_id
        entity_str = entity.class.name
        entity_str += "#" + entity.id.to_s if entity.id.present?
      else
        entity_str = entity.to_s
      end

      entity_str
    end

    def action_to_string(action)
      ACTION_NAMES[action]
    end

    def action_to_color(action)
      ACTION_COLORS[action] || 'white'
    end
  end
end
