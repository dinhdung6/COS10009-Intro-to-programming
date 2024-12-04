require 'ruby2d'

# Set up window
set width: 800, height: 600

# Define the maze layout (1 = wall, 0 = path)
$maze = [
  [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
  [1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1],
  [1, 0, 1, 0, 1, 0, 1, 1, 1, 1, 0, 1, 0, 1, 0, 1],
  [1, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1],
  [1, 0, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 0, 1],
  [1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 1],
  [1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 0, 1, 1, 1],
  [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1],
  [1, 0, 1, 1, 0, 1, 1, 1, 1, 1, 0, 1, 1, 1, 0, 1],
  [1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1],
  [1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 0, 1],
  [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1],
  [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1],
  [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
  [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
]

# Define the size of each cell in the maze
CELL_SIZE = 40

# Function to draw the maze
def draw_maze(maze, cell_size)
  maze.each_with_index do |row, y|
    row.each_with_index do |cell, x|
      if cell == 1
        Rectangle.new(
          x: x * cell_size,
          y: y * cell_size,
          width: cell_size,
          height: cell_size,
          color: 'gray'
        )
      end
    end
  end
end

# Function to get a random valid position in the maze
def random_valid_position(maze, cell_size)
  loop do
    x = rand(maze[0].length) * cell_size
    y = rand(maze.length) * cell_size
    x_cell = x / cell_size
    y_cell = y / cell_size
    if maze[y_cell][x_cell] == 0
      return [x, y]
    end
  end
end

# Function to set ruby position randomly
def set_ruby_position(cell_size)
  x, y = random_valid_position($maze, cell_size)
  @ruby.x = x
  @ruby.y = y
end

# Player sprite
@sprite = Sprite.new(
  'character.png',
  x: CELL_SIZE,
  y: CELL_SIZE,
  clip_width: 60,
  animations: { fly: 1..3 }
)
@sprite.width = CELL_SIZE
@sprite.height = CELL_SIZE

# Ruby image
@ruby = Image.new(
  'ruby.png',
  x: 0,
  y: 0
)
@ruby.width = CELL_SIZE
@ruby.height = CELL_SIZE

# Set ruby position randomly
set_ruby_position(CELL_SIZE)

# Sound effects
@sound = Sound.new('jump.ogg')
@death_sound = Sound.new('pixel-death-66829.mp3')
@music = Music.new('background_music.ogg', loop: true)
@music.play

# Texts
@title_text = Text.new(
  'Maze Game',
  x: 180,
  y: 10,
  size: 42,
  color: 'black'
)

@score = 0
@score_text = Text.new(
  "Score: #{@score}",
  x: 10,
  y: 10,
  size: 20,
  color: 'black'
)

@game_over_text = nil

# Function to reset the game
def reset_game
  close
end

# Function to check collision with walls
def wall_collision?(x, y, maze, cell_size)
  x1 = (x / cell_size).to_i
  y1 = (y / cell_size).to_i
  x2 = ((x + cell_size - 1) / cell_size).to_i
  y2 = ((y + cell_size - 1) / cell_size).to_i
  maze[y1][x1] == 1 || maze[y1][x2] == 1 || maze[y2][x1] == 1 || maze[y2][x2] == 1
end

# Function to check collision between two objects
def check_collision(object1, object2)
  object1.x < object2.x + object2.width &&
  object1.x + object1.width > object2.x &&
  object1.y < object2.y + object2.height &&
  object1.y + object1.height > object2.y
end

# Draw the maze initially
draw_maze($maze, CELL_SIZE)

# Event handlers
on :key_held do |event|
  next if @score >= 2 # Do not process key events if game is over

  @sprite.play(animation: :fly)

  new_x = @sprite.x
  new_y = @sprite.y

  case event.key
  when 'up'
    new_y -= 5
  when 'down'
    new_y += 5
  when 'left'
    new_x -= 5
  when 'right'
    new_x += 5
  end

  unless wall_collision?(new_x, new_y, $maze, CELL_SIZE)
    @sprite.x = new_x
    @sprite.y = new_y
  end

  # Check for collision with ruby and update score
  if check_collision(@sprite, @ruby)
    @score += 1
    @score_text.text = "Score: #{@score}"
    @sound.play  # Play the sound when the ruby is touched
    set_ruby_position(CELL_SIZE)  # Move the ruby to a new position
    if @score >= 1 && @game_over_text.nil?
      @game_over_text = Text.new(
        'You win, let\'s move on to other levels! Press space to exit',
        x: 100,
        y: 200,
        size: 30,
        color: 'green'
      )
    end
  end
end

on :key_up do
  @sprite.stop
end

on :key_down do |event|
  if event.key == 'space' && @game_over_text
    reset_game
  end
end

show
