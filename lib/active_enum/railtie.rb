module ActiveEnum 
  class Railtie < Rails::Railtie
    initializer "active_enum.active_record_extensions" do
      ActiveSupport.on_load(:active_record) do
        require 'active_enum/acts_as_enum'
        
        unless ActiveRecord::Base.include?(ActiveEnum::Extensions)
          ActiveRecord::Base.send(:include, ActiveEnum::Extensions)
        end
      end
    end
  end
end
