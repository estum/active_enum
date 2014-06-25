require 'active_support/configurable'
require 'active_enum/base'
require 'active_enum/extensions'
require 'active_enum/storage/abstract_store'
require 'active_enum/version'
require 'active_enum/railtie' if defined?(Rails)

module ActiveEnum
  include ActiveSupport::Configurable
  config_accessor :enum_classes do
    []
  end

  config_accessor :use_name_as_value do
    false
  end

  config_accessor :storage do
    :memory
  end

  config_accessor :storage_options do
    {}
  end

  def storage=(*args)
    config.storage_options = args.extract_options!
    config.storage = args.first
  end

  config_accessor :extend_classes do
    []
  end
  
  # Setup method for plugin configuration
  def self.setup
    yield config
    extend_classes!
  end

  class EnumDefinitions
    def enum(name, &block)
      class_name = name.to_s.camelize
      eval("class #{class_name} < ActiveEnum::Base; end", TOPLEVEL_BINDING)
      new_enum = Module.const_get(class_name)
      new_enum.class_eval(&block)
    end
  end

  # Define enums in bulk
  def self.define(&block)
    raise "Define requires block" unless block_given?
    EnumDefinitions.new.instance_eval(&block)
  end
  
  def self.storage_class
    @storage_class ||= "ActiveEnum::Storage::#{storage.to_s.classify}Store".constantize
  end

  private

  def self.extend_classes!
    config.extend_classes.each {|klass| klass.send(:include, ActiveEnum::Extensions) }
  end

end
