require 'ruby2d'
require 'thread'

# Set up window
set title: "Game Launcher"
set width: 800, height: 600

# Welcome text
welcome_text = Text.new(
  'Welcome Player!',
  x: 250, y: 100,
  size: 40,
  color: 'blue'
)

# Level selection text
level_text = Text.new(
  'Choose your level:',
  x: 300, y: 200,
  size: 30,
  color: 'white'
)

# Level 1 button
level1_button = Rectangle.new(
  x: 250, y: 300,
  width: 300, height: 50,
  color: 'green'
)

level1_text = Text.new(
  'Level 1: Maze Game',
  x: 300, y: 315,
  size: 20,
  color: 'white'
)

# Level 2 button
level2_button = Rectangle.new(
  x: 250, y: 400,
  width: 300, height: 50,
  color: 'red'
)

level2_text = Text.new(
  'Level 2: Collector Game',
  x: 300, y: 415,
  size: 20,
  color: 'white'
)

# Level 3 button
level3_button = Rectangle.new(
  x: 250, y: 500,
  width: 300, height: 50,
  color: 'blue'
)

level3_text = Text.new(
  'Level 3: Avoid Game',
  x: 300, y: 515,
  size: 20,
  color: 'white'
)

# Function to launch a game in a new thread
def launch_game(game_file)
  Thread.new do
    # Use exec to run the game, but ensure it runs in its own thread
    system("ruby #{game_file}")
  end
end

# Mouse click event
on :mouse_down do |event|
  if level1_button.contains?(event.x, event.y)
    launch_game('maze_game.rb')
  elsif level2_button.contains?(event.x, event.y)
    launch_game('collector_game.rb')
  elsif level3_button.contains?(event.x, event.y)
    launch_game('avoid_game.rb')
  end
end

# Show the welcome screen
show
