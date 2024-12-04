require 'ruby2d'
set width: 600
set height: 400

# Load assets
@background_image = Image.new('612.jpg')

@sprite = Sprite.new(
  'character.png',
  x: 50,
  y: 240,
  clip_width: 60,
  animations: { fly: 1..3 }
)

@sprite.width = 60
@sprite.height = 60

# Use the new obstacle image and rotate it by 90 degrees
@obstacle_image = '4588756.png'
@sound = Sound.new('jump.ogg')
@death_sound = Sound.new('pixel-death-66829.mp3')
@music = Music.new("background_music.ogg", loop: true)
@music.play

@title_text = Text.new(
  'Avoid the knives!',
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

# Variables
@obstacles = []
@obstacle_speed = 2
@spawn_interval = 60
@frames_until_spawn = @spawn_interval

@game_over_text = nil
@win_text = nil

# Function to reset the game
def reset_game
  @sprite.y = 240
  @obstacles.each { |obs| obs[:image].remove; obs[:hitbox].remove }
  @obstacles.clear
  @score = 0
  @score_text.text = "Score: #{@score}"
  @game_over_text.remove if @game_over_text
  @game_over_text = nil
  @win_text.remove if @win_text
  @win_text = nil
end

# Function to create a new obstacle
def spawn_obstacle
  obstacle = Image.new(
    @obstacle_image,
    x: 640,
    y: rand(get(:height) - 60),
    rotate: 230
  )
  obstacle.width = 60
  obstacle.height = 60

  # Create a smaller hitbox for the obstacle
  hitbox = Rectangle.new(
    x: obstacle.x + 10,
    y: obstacle.y + 10,
    width: 40,
    height: 40,
    color: [0, 0, 0, 0]  # Fully transparent color
  )

  @obstacles << { image: obstacle, hitbox: hitbox }
end

# Function to check collision
def check_collision(object1, object2)
  object1.x < object2.x + object2.width &&
  object1.x + object1.width > object2.x &&
  object1.y < object2.y + object2.height &&
  object1.y + object1.height > object2.y
end

# Event handlers
on :key_held do |event|
  next if @game_over_text || @win_text # Do not process key events if game is over or won

  @sprite.play(animation: :fly)

  case event.key
  when 'up'
    @sprite.y -= 5 if @sprite.y > 0
  when 'down'
    @sprite.y += 5 if @sprite.y < get(:height) - @sprite.height
  end
end

on :key_up do
  @sprite.stop
end

on :key_down do |event|
  if event.key == 'space'
    if @game_over_text
      reset_game
    elsif @win_text
      close
    end
  end
end

update do
  unless @game_over_text || @win_text
    # Move obstacles
    @obstacles.each do |obstacle|
      obstacle[:image].x -= @obstacle_speed
      obstacle[:hitbox].x -= @obstacle_speed

      if obstacle[:image].x + obstacle[:image].width < 0
        obstacle[:image].remove
        obstacle[:hitbox].remove
        @obstacles.delete(obstacle)
        @score += 1
        @score_text.text = "Score: #{@score}"

        # Check if player has won
        if @score >= 30
          @win_text = Text.new(
            'You Win! Press space to close the window',
            x: 100,
            y: 200,
            size: 30,
            color: 'green'
          )
        end
      elsif check_collision(@sprite, obstacle[:hitbox])
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

    # Spawn new obstacles
    @frames_until_spawn -= 1
    if @frames_until_spawn <= 0
      spawn_obstacle
      @frames_until_spawn = @spawn_interval
    end
  end
end

show
