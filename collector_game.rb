require 'ruby2d'
set width: 640
set height: 480

@background_image = Image.new('background.png')

@circle = Circle.new(
  color: 'yellow',
  x: 20,
  y: 20,
  radius: 90
)

@triangle = Triangle.new(
  color: 'orange',
  x1: 0, y1: 0,
  x2: 40, y2: 0,
  x3: 0, y3: 40,
)

@sprite = Sprite.new(
  'character.png',
  x: 100,
  y: 380,
  clip_width: 60,
  animations: { fly: 1..3 }
)

# Set sprite width and height explicitly
@sprite.width = 60
@sprite.height = 60

@sound = Sound.new('jump.ogg')
@death_sound = Sound.new('pixel-death-66829.mp3')

@music = Music.new("background_music.ogg", loop: true)
@music.play

@title_text = Text.new(
  'My Ruby 2D Game',
  x: 180,
  y: 10,
  size: 42,
  color: 'black'
)

# Score display
@score = 10
@score_text = Text.new(
  "Score: #{@score}",
  x: 10,
  y: 10,
  size: 20,
  color: 'black'
)

# Ruby image
@ruby = Image.new('ruby.png', x: rand(get(:width)), y: rand(get(:height)))

# Set ruby width and height explicitly
@ruby.width = 32
@ruby.height = 32

# Monster image
@monster = Image.new('Crab_shadow1.png', x: rand(get(:width)), y: rand(get(:height)))

# Set monster width and height explicitly
@monster.width = 60
@monster.height = 60

# Variables to hold the game over and win text objects
@game_over_text = nil
@win_text = nil

# Variable to track the current background
@current_background = 'background.png'

# Function to move ruby to a random position
def move_ruby(ruby)
  ruby.x = rand(get(:width) - ruby.width)
  ruby.y = rand(get(:height) - ruby.height)
end

# Function to move monster towards the player
def move_monster(monster, sprite)
  if monster.x < sprite.x
    monster.x += 1
  elsif monster.x > sprite.x
    monster.x -= 1
  end

  if monster.y < sprite.y
    monster.y += 1
  elsif monster.y > sprite.y
    monster.y -= 1
  end
end

# Function to check collision
def check_collision(object1, object2)
  object1.x < object2.x + object2.width &&
  object1.x + object1.width > object2.x &&
  object1.y < object2.y + object2.height &&
  object1.y + object1.height > object2.y
end

# Function to reset the game
def reset_game(sprite, ruby, monster, score_text)
  @sprite.x = 100
  @sprite.y = 380
  move_ruby(@ruby)
  @monster.x = rand(get(:width))
  @monster.y = rand(get(:height))
  @score = 10
  @score_text.text = "Score: #{@score}"
  @game_over_text.remove if @game_over_text
  @game_over_text = nil
  @win_text.remove if @win_text
  @win_text = nil
end

# Function to switch the background
def switch_background
  @background_image.remove
  @background_image = Image.new(@current_background == 'background.png' ? '7438514.jpg' : 'background.png')
  @current_background = @current_background == 'background.png' ? '7438514.jpg' : 'background.png'

  # Remove and re-create other game elements so they appear on top of the background
  @circle.remove
  @circle = Circle.new(
    color: 'yellow',
    x: 20,
    y: 20,
    radius: 90
  )

  @triangle.remove
  @triangle = Triangle.new(
    color: 'orange',
    x1: 0, y1: 0,
    x2: 40, y2: 0,
    x3: 0, y3: 40,
  )

  @title_text.remove
  @title_text = Text.new(
    'My Ruby 2D Game',
    x: 180,
    y: 10,
    size: 42,
    color: 'black'
  )

  @score_text.remove
  @score_text = Text.new(
    "Score: #{@score}",
    x: 10,
    y: 10,
    size: 20,
    color: 'black'
  )

  @ruby.remove
  @ruby = Image.new('ruby.png', x: rand(get(:width)), y: rand(get(:height)))

  # Set ruby width and height explicitly
  @ruby.width = 32
  @ruby.height = 32

  @monster.remove
  @monster = Image.new('Crab_shadow1.png', x: rand(get(:width)), y: rand(get(:height)))

  # Set monster width and height explicitly
  @monster.width = 60
  @monster.height = 60

  @sprite.remove
  @sprite = Sprite.new(
    'character.png',
    x: 100,
    y: 380,
    clip_width: 60,
    animations: { fly: 1..3 }
  )

  # Set sprite width and height explicitly
  @sprite.width = 60
  @sprite.height = 60
end

# Event handlers
on :key_held do |event|
  next if @score <= 0 || @win_text # Do not process key events if game is over or won

  @sprite.play(animation: :fly)

  case event.key
  when 'up'
    @sprite.y -= 5
  when 'down'
    @sprite.y += 5
  when 'left'
    @sprite.x -= 5
  when 'right'
    @sprite.x += 5
  end

  # Check for collision with ruby and update score
  if check_collision(@sprite, @ruby)
    @score += 1
    @score_text.text = "Score: #{@score}"
    move_ruby(@ruby)
    @sound.play  # Play the sound when the ruby is touched

    # Check if player has won
    if @score >= 20
      @win_text = Text.new(
        'You Win! Press space and move on other level',
        x: 100,
        y: 200,
        size: 30,
        color: 'green'
      )
    end
  end

  # Check if sprite flies outside the border and switch background
  if @sprite.x < 0
    @sprite.x = get(:width) - @sprite.width
    switch_background
  elsif @sprite.x + @sprite.width > get(:width)
    @sprite.x = 0
    switch_background
  elsif @sprite.y < 0
    @sprite.y = get(:height) - @sprite.height
    switch_background
  elsif @sprite.y + @sprite.height > get(:height)
    @sprite.y = 0
    switch_background
  end
end

on :key_up do
  @sprite.stop
end

on :key_down do |event|
  if event.key == 'space'
    if @score <= 0
      reset_game(@sprite, @ruby, @monster, @score_text)
    elsif @win_text
      close
    end
  end
end

update do
  if @score > 0 && !@win_text
    move_monster(@monster, @sprite)

    # Check for collision with monster and update score
    if check_collision(@sprite, @monster)
      @score -= 1
      @score_text.text = "Score: #{@score}"
      if @score <= 0
        @death_sound.play
        @game_over_text = Text.new(
          'Game Over! Press space to play again',
          x: 100,
          y: 200,
          size: 30,
          color: 'red'
        )
      end
    end
  elsif !@game_over_text && !@win_text
    @game_over_text = Text.new(
      'Game Over! Press space to play again',
      x: 100,
      y: 200,
      size: 30,
      color: 'red'
    )
  end
end

show
