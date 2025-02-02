class InMemoryAgent
  attr_reader :events

  def initialize
    @events = []
  end

  def setup
    @events = []
  end

  def create_web_application_info(name:, unique_name:, context_root:)
    @web_application_info = {
      name:,
      unique_name:,
      context_root:
    }
  end

  def trace(env)
    @events << env
  end
end