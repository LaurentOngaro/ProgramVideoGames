// Program Video Games first mini-course
// Day 5: Putting It All Together: Building a Simple Game
// personnal version

package main

import "core:fmt"
import "core:math"
import "core:math/linalg"
import "core:math/rand"
import rl "vendor:raylib"

gameState :: struct {
  fpsLimit:         i32,
  windowsSize:      rl.Vector2,
  //
  ball:             rl.Rectangle,
  ballSpeed:        f32,
  ballDirection:    rl.Vector2,
  //
  paddle:           rl.Rectangle,
  paddleSpeed:      f32,
  //
  CPUpaddle:        rl.Rectangle,
  CPUtarget:        rl.Vector2,
  CPUreactionTimer: f32,
  CPUpaddleSpeed:   f32,
  CPUinaccuracy:    f32,
  CPUreactionDelay: f32,
  //
  scorePlayer:      int,
  scoreCPU:         int,
  boostTimer:       f32,
}

/* NOTES:
  ALL THE FOLDERS Must be relative to the folder where the executable is run and NOT TO the folder where the Odin main file is
  */
// folder for the assets
assetsFolder: string : "../../assets"
// folder for the source files
srcFolder: string : "../../src"

// Main entry point of the program
main :: proc() {
  gs: gameState = {
    fpsLimit         = 60,
    windowsSize      = {1280, 720},
    //
    ball             = {-1, -1, 30, 30}, // position will be set in reset
    ballSpeed        = 10,
    //
    paddle           = {-1, -1, 20, 100}, // position will be set in reset
    paddleSpeed      = 10,
    //
    CPUpaddle        = {-1, -1, 20, 100}, // position will be set in reset
    CPUreactionTimer = 0,
    CPUtarget        = {0, 0},
    //change the following values to change the difficulty by making the CPU more or less efficient
    CPUpaddleSpeed   = 8,
    CPUinaccuracy    = 30,
    CPUreactionDelay = 0.1,
    //
    scorePlayer      = 0,
    scoreCPU         = 0,
    boostTimer       = 0,
  }

  reset(&gs)

  // init graphics
  rl.InitWindow(i32(gs.windowsSize.x), i32(gs.windowsSize.y), "Pong")
  rl.SetTargetFPS(gs.fpsLimit)

  /// init sounds
  rl.InitAudioDevice()

  rl_assetsFolder :: cstring(assetsFolder) // we need a cstring to pass the value to the raylib functions
  soundHit := rl.LoadSound(rl_assetsFolder + "/sounds/hit.wav")
  soundWin := rl.LoadSound(rl_assetsFolder + "/sounds/win.wav")
  soundLose := rl.LoadSound(rl_assetsFolder + "/sounds/lose.wav")

  defer {
    rl.UnloadSound(soundWin)
    rl.UnloadSound(soundLose)
    rl.UnloadSound(soundHit)
    rl.CloseAudioDevice()
    rl.CloseWindow()
    fmt.printfln("Freeing loaded resources")
  }

  for !rl.WindowShouldClose() {
    deltaTime: f32 = rl.GetFrameTime()
    gs.boostTimer -= deltaTime

    // Player's actions
    // ------
    // move the player paddle by handling keybords events using WASD ou arrows keys
    if rl.IsKeyDown(rl.KeyboardKey.A) || rl.IsKeyDown(rl.KeyboardKey.LEFT) {
      gs.paddle.x -= gs.paddleSpeed
    } else if rl.IsKeyDown(rl.KeyboardKey.D) || rl.IsKeyDown(rl.KeyboardKey.RIGHT) {
      gs.paddle.x += gs.paddleSpeed
    }
    if rl.IsKeyDown(rl.KeyboardKey.W) || rl.IsKeyDown(rl.KeyboardKey.UP) {
      gs.paddle.y -= gs.paddleSpeed
    } else if rl.IsKeyDown(rl.KeyboardKey.S) || rl.IsKeyDown(rl.KeyboardKey.DOWN) {
      gs.paddle.y += gs.paddleSpeed
    }
    // add a boost to the ball by usgin the spaceBar
    if rl.IsKeyDown(rl.KeyboardKey.SPACE) {
      // boost the ball for .2 seconds
      if gs.boostTimer < 0 {
        gs.boostTimer = 0.5
      }
    }
    // move the CPU paddle
    // ------
    // increase timer by time between last frame and this one
    gs.CPUreactionTimer += deltaTime
    // if the timer is done:
    if gs.CPUreactionTimer >= gs.CPUreactionDelay {
      // reset the timer
      gs.CPUreactionTimer = 0
      // if the ball is heading right, the CPU player moves toward the ball
      // Note: it should be inversed if the ball goes left
      if gs.ballDirection.x > 0 {
        ballCenterY := gs.ball.y + gs.ball.height / 2
        // set the target to the ball
        gs.CPUtarget.y = ballCenterY - gs.CPUpaddle.height / 2
        // add or subtract 0-20 to add inaccuracy
        gs.CPUtarget.y += rand.float32_range(-gs.CPUinaccuracy, gs.CPUinaccuracy)
      } else {
        // set the target to screen middle
        gs.CPUtarget.y = gs.windowsSize.y / 2 - gs.CPUpaddle.height / 2
      }
    }
    // calculate the distance between the CPU paddle and its target
    targetDiffy := gs.CPUtarget.y - gs.CPUpaddle.y
    // move either paddle_speed distance or less
    gs.CPUpaddle.y += linalg.clamp(targetDiffy, -gs.CPUpaddleSpeed, gs.CPUpaddleSpeed)

    // update ball position
    // ------
    ballVelocity: rl.Vector2 = gs.ballDirection * gs.ballSpeed
    nextBallRect: rl.Rectangle = {(gs.ball.x + ballVelocity.x), (gs.ball.y + ballVelocity.y), gs.ball.width, gs.ball.height}
    // check win/lose conditions
    if nextBallRect.x >= gs.windowsSize.x - gs.ball.width {
      // CPU loses
      rl.PlaySound(soundWin)
      gs.scorePlayer += 1
      reset(&gs)
    } else if nextBallRect.x < 0 {
      // player loses
      rl.PlaySound(soundLose)
      gs.scoreCPU += 1
      reset(&gs)
    } else {
      // no one loose, we update the ball and player position
      if (nextBallRect.x >= gs.windowsSize.x - gs.ball.width || nextBallRect.x <= 0) {reset(&gs)}
      if (nextBallRect.y >= gs.windowsSize.y - gs.ball.height || nextBallRect.y <= 0) {gs.ballDirection.y *= -1}

      gs.paddle.x = linalg.clamp(gs.paddle.x, 0, gs.windowsSize.x - gs.paddle.width)
      gs.paddle.y = linalg.clamp(gs.paddle.y, 0, gs.windowsSize.y - gs.paddle.height)
      gs.CPUpaddle.x = linalg.clamp(gs.CPUpaddle.x, 0, gs.windowsSize.x - gs.CPUpaddle.width)
      gs.CPUpaddle.y = linalg.clamp(gs.CPUpaddle.y, 0, gs.windowsSize.y - gs.CPUpaddle.height)

      oldBallDirection := gs.ballDirection
      gs.ballDirection = calculateBallDirection(nextBallRect, gs.paddle) or_else gs.ballDirection
      if oldBallDirection != gs.ballDirection {
        // the ball hit the Player paddle ONLY
        if gs.boostTimer > 0 {
          // boost timer / 0.2 will give us a percentage (let's say 30%)
          // we add 1 because we want to increase the speed (130%)
          boostBallSpeed := 1 + gs.boostTimer / 0.6
          fmt.printfln("BOOST: %v", boostBallSpeed)
          gs.ballDirection *= boostBallSpeed
        }
      }
      gs.ballDirection = calculateBallDirection(nextBallRect, gs.CPUpaddle) or_else gs.ballDirection
      if oldBallDirection != gs.ballDirection {
        // the ball hit the Player OR the CPU paddle
        rl.PlaySound(soundHit)
      }
      gs.ball.x += gs.ballDirection.x * gs.ballSpeed
      gs.ball.y += gs.ballDirection.y * gs.ballSpeed
    }

    // Objects rendering
    // ------
    rl.BeginDrawing()
    rl.ClearBackground(rl.BLACK)
    // Draw the game title text
    rl.DrawText("This is ODIN Pong", i32(gs.windowsSize.x / 2 - 100), 2, 30, rl.BLUE)
    // Draw the scores
    rl.DrawText(fmt.ctprintf("Player:{}", gs.scorePlayer), 30, 2, 20, rl.ORANGE)
    rl.DrawText(fmt.ctprintf("CPU:{}", gs.scoreCPU), i32(gs.windowsSize.x) - 90, 2, 20, rl.ORANGE)
    /* NOTE:
      ctprintf will create a temporary string using the context.temp_allocator object.
      It must be freed at the end of the prog to avoid memory leaks.
    */

    // Draw the ball
    rl.DrawRectangleRec(gs.ball, rl.RED)
    // Draw the player's paddle
    if gs.boostTimer > 0 {
      fadeValue := u8(255 * (0.2 / gs.boostTimer))
      rl.DrawRectangleRec(gs.paddle, {255, fadeValue, fadeValue, 255})
    } else {
      rl.DrawRectangleRec(gs.paddle, rl.WHITE)
    }
    // Draw the CPU's paddle
    rl.DrawRectangleRec(gs.CPUpaddle, rl.GRAY)
    rl.EndDrawing()
    free_all(context.temp_allocator)
  }

}

// Reset the game state
reset :: proc(using gs: ^gameState) {
  paddleMargin: f32 = 50

  // Generate a random angle for the ball's initial direction
  angle := rand.float32_range(-45, 46)

  // The ball can go left or right at start to serve both players randomly
  if rand.int_max(100) % 2 == 0 do angle += 180

  // Convert the angle to radians
  r := math.to_radians(angle)

  // Set the ball's direction based on the angle
  ballDirection.x = math.cos(r)
  ballDirection.y = math.sin(r)

  // Position the ball in the center of the window
  ball.x = windowsSize.x / 2 - ball.width / 2
  ball.y = windowsSize.y / 2 - ball.height / 2

  // Position the player's paddle
  paddle.x = paddleMargin
  paddle.y = windowsSize.y / 2 - paddle.height / 2

  // Position the CPU's paddle
  CPUpaddle.x = windowsSize.x - paddleMargin - gs.paddle.width
  CPUpaddle.y = windowsSize.y / 2 - paddle.height / 2
}

// Calculate the new direction of the ball after collision with a paddle
calculateBallDirection :: proc(ball: rl.Rectangle, paddle: rl.Rectangle) -> (rl.Vector2, bool) {
  // Check if the ball collides with the paddle
  if rl.CheckCollisionRecs(ball, paddle) {
    // Calculate the centers of the ball and the paddle
    ballCenter := rl.Vector2{ball.x + ball.width / 2, ball.y + ball.height / 2}
    paddleCenter := rl.Vector2{paddle.x + paddle.width / 2, paddle.y + paddle.height / 2}

    // Return the normalized direction vector and true indicating a collision
    return linalg.normalize0(ballCenter - paddleCenter), true
  }

  // Return an empty vector and false indicating no collision
  return {}, false
}
