class InMemoryAgent
  attr_reader :events

  def initialize
    @events = []
  end

  def setup
    @events = []
  end
end
