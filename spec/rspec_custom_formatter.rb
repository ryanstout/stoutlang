require 'rspec/core/formatters/base_text_formatter'

class RspecCustomFormatter < RSpec::Core::Formatters::BaseTextFormatter
  RSpec::Core::Formatters.register self, :example_started

  def example_started(notification)
    output.puts notification.example.location
  end
end
