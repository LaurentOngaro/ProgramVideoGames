// Program Video Games first mini-course
// Day 5: Putting It All Together: Building a Simple Game
// personnal version

package main

import "core:math"
import "core:math/linalg"
import "core:math/rand"
import rl "vendor:raylib"

gameState :: struct {
  fpsLimit:        i32,
  windowsSize:     rl.Vector2,
  //
  ball:            rl.Rectangle,
  ballSpeed:       f32,
  ballDirection:   rl.Vector2,
  //
  paddle:          rl.Rectangle,
  paddleSpeed:     f32,
  //
  AIpaddle:        rl.Rectangle,
  AItarget:        rl.Vector2,
  AIreactionTimer: f32,
  AIpaddleSpeed:   f32,
  AIinaccuracy:    f32,
  AIreactionDelay: f32,
  //
  scorePlayer:     int,
  scoreAI:         int,
}

// Main entry point of the program
main :: proc() {
  gs: gameState = {
    fpsLimit = 60,
    windowsSize = {1280, 720},
    //
    ball = {-1, -1, 30, 30}, // position will be set in reset
    ballSpeed = 10,
    //
    paddle = {-1, -1, 20, 100}, // position will be set in reset
    paddleSpeed = 10,
    //
    AIpaddle = {-1, -1, 20, 100}, // position will be set in reset
    AIreactionTimer = 0,
    AItarget = {0, 0},
    //change the following values to change the difficulty by making the AI more or less efficient
    AIpaddleSpeed = 8,
    AIinaccuracy = 30,
    AIreactionDelay = 0.1,
    scorePlayer = 0,
    scoreAI = 0,
  }

  reset(&gs)

  rl.InitWindow(i32(gs.windowsSize.x), i32(gs.windowsSize.y), "Pong")
  rl.SetTargetFPS(gs.fpsLimit)

  for !rl.WindowShouldClose() {
    // move the player paddle by handling keybords events
    // ------
    if rl.IsKeyDown(rl.KeyboardKey.A) {
      gs.paddle.x -= gs.paddleSpeed
    } else if rl.IsKeyDown(rl.KeyboardKey.D) {
      gs.paddle.x += gs.paddleSpeed
    }
    if rl.IsKeyDown(rl.KeyboardKey.W) {
      gs.paddle.y -= gs.paddleSpeed
    } else if rl.IsKeyDown(rl.KeyboardKey.S) {
      gs.paddle.y += gs.paddleSpeed
    }

    // move the AI paddle
    // ------
    // increase timer by time between last frame and this one
    gs.AIreactionTimer += rl.GetFrameTime()
    // if the timer is done:
    if gs.AIreactionTimer >= gs.AIreactionDelay {
      // reset the timer
      gs.AIreactionTimer = 0
      // if the ball is heading right, the AI player moves toward the ball
      // Note: it should be inversed if the ball goes left
      if gs.ballDirection.x > 0 {
        ballCenterY := gs.ball.y + gs.ball.height / 2
        // set the target to the ball
        gs.AItarget.y = ballCenterY - gs.AIpaddle.height / 2
        // add or subtract 0-20 to add inaccuracy
        gs.AItarget.y += rand.float32_range(-gs.AIinaccuracy, gs.AIinaccuracy)
      } else {
        // set the target to screen middle
        gs.AItarget.y = gs.windowsSize.y / 2 - gs.AIpaddle.height / 2
      }
    }
    // calculate the distance between the AI paddle and its target
    targetDiffy := gs.AItarget.y - gs.AIpaddle.y
    // move either paddle_speed distance or less
    gs.AIpaddle.y += linalg.clamp(targetDiffy, -gs.AIpaddleSpeed, gs.AIpaddleSpeed)

    // update ball position
    // ------
    ballVelocity: rl.Vector2 = gs.ballDirection * gs.ballSpeed
    nextBallRect: rl.Rectangle = {(gs.ball.x + ballVelocity.x), (gs.ball.y + ballVelocity.y), gs.ball.width, gs.ball.height}
    // check win/lose conditions
    if nextBallRect.x >= gs.windowsSize.x - gs.ball.width {
      // AI loses
      gs.scorePlayer += 1
      reset(&gs)
    } else if nextBallRect.x < 0 {
      // player loses
      gs.scoreAI += 1
      reset(&gs)
    } else {
      // no one loose, we update the ball and player position
      if (nextBallRect.x >= gs.windowsSize.x - gs.ball.width || nextBallRect.x <= 0) {reset(&gs)}
      if (nextBallRect.y >= gs.windowsSize.y - gs.ball.height || nextBallRect.y <= 0) {gs.ballDirection.y *= -1}

      gs.paddle.x = linalg.clamp(gs.paddle.x, 0, gs.windowsSize.x - gs.paddle.width)
      gs.paddle.y = linalg.clamp(gs.paddle.y, 0, gs.windowsSize.y - gs.paddle.height)
      gs.AIpaddle.x = linalg.clamp(gs.AIpaddle.x, 0, gs.windowsSize.x - gs.AIpaddle.width)
      gs.AIpaddle.y = linalg.clamp(gs.AIpaddle.y, 0, gs.windowsSize.y - gs.AIpaddle.height)

      gs.ballDirection = ball_dir_calculate(nextBallRect, gs.paddle) or_else gs.ballDirection
      gs.ballDirection = ball_dir_calculate(nextBallRect, gs.AIpaddle) or_else gs.ballDirection

      gs.ball.x += gs.ballDirection.x * gs.ballSpeed
      gs.ball.y += gs.ballDirection.y * gs.ballSpeed
    }

    // Objects rendering
    // ------
    rl.BeginDrawing()
    rl.ClearBackground(rl.BLACK)
    // Draw the game title text
    rl.DrawText("This is ODIN Pong", i32(gs.windowsSize.x / 2 - 80), 2, 20, rl.BLUE)
    // Draw the ball
    rl.DrawRectangleRec(gs.ball, rl.RED)
    // Draw the player's paddle
    rl.DrawRectangleRec(gs.paddle, rl.WHITE)
    // Draw the AI's paddle
    rl.DrawRectangleRec(gs.AIpaddle, rl.GRAY)
    rl.EndDrawing()
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

  // Position the AI's paddle
  AIpaddle.x = windowsSize.x - paddleMargin - gs.paddle.width
  AIpaddle.y = windowsSize.y / 2 - paddle.height / 2
}

// Calculate the new direction of the ball after collision with a paddle
ball_dir_calculate :: proc(ball: rl.Rectangle, paddle: rl.Rectangle) -> (rl.Vector2, bool) {
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
