// Program Video Games first mini-course
// Day 3: Simple collisions, multiple moving objects
// personnal version

package main

import "core:math"
import "core:math/linalg"
import "core:math/rand"
import rl "vendor:raylib"

gameState :: struct {
  fpsLimit:      i32,
  windowsSize:   rl.Vector2,
  //
  paddle:        rl.Rectangle,
  paddleSpeed:   f32,
  //
  ball:          rl.Rectangle,
  ballSpeed:     f32,
  ballDirection: rl.Vector2,
}

main :: proc() {
  gs: gameState = {
    fpsLimit = 60,
    windowsSize = {1280, 720},
    //
    paddle = {-1, -1, 20, 100}, // position will be set in reset
    paddleSpeed = 10,
    //
    ball = {-1, -1, 30, 30}, // position will be set in reset
    ballSpeed = 10,
  }

  reset(&gs)

  rl.InitWindow(i32(gs.windowsSize.x), i32(gs.windowsSize.y), "Pong")
  rl.SetTargetFPS(gs.fpsLimit)

  for !rl.WindowShouldClose() {
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

    ballVelocity: rl.Vector2 = gs.ballDirection * gs.ballSpeed

    nextBallRect: rl.Rectangle = {(gs.ball.x + ballVelocity.x), (gs.ball.y + ballVelocity.y), gs.ball.width, gs.ball.height}

    // When the ball is out of screen
    // DEBUG: bounce
    //if (nextBallRect.x > gs.windowsSize.x - gs.ball.width || nextBallRect.x < 0) {gs.ballDirection.x *= -1}
    // REAL: reset the game (lost)
    if (nextBallRect.x >= gs.windowsSize.x - gs.ball.width || nextBallRect.x <= 0) {reset(&gs)}
    if (nextBallRect.y >= gs.windowsSize.y - gs.ball.height || nextBallRect.y <= 0) {gs.ballDirection.y *= -1}

    gs.paddle.x = linalg.clamp(gs.paddle.x, 0, gs.windowsSize.x - gs.paddle.width)
    gs.paddle.y = linalg.clamp(gs.paddle.y, 0, gs.windowsSize.y - gs.paddle.height)

    if rl.CheckCollisionRecs(nextBallRect, gs.paddle) {
      ballCenter := rl.Vector2{(nextBallRect.x - nextBallRect.width) / 2, (nextBallRect.y - nextBallRect.height) / 2}
      paddleCenter := rl.Vector2{(gs.paddle.x - gs.paddle.width) / 2, (gs.paddle.y - gs.paddle.height) / 2}
      gs.ballDirection = linalg.normalize0(ballCenter - paddleCenter)
    }

    gs.ball.x += gs.ballDirection.x * gs.ballSpeed
    gs.ball.y += gs.ballDirection.y * gs.ballSpeed

    rl.BeginDrawing()
    rl.ClearBackground(rl.BLACK)
    rl.DrawText("This is Pong", i32(gs.windowsSize.x / 2 - 80), 2, 20, rl.BLUE)
    rl.DrawRectangleRec(gs.paddle, rl.WHITE)
    rl.DrawRectangleRec(gs.ball, rl.RED)
    rl.EndDrawing()
  }
}

reset :: proc(using gs: ^gameState) {
  angle := rand.float32_range(-45, 46)
  r := math.to_radians(angle)

  ballDirection.x = math.cos(r)
  ballDirection.y = math.sin(r)

  ball.x = windowsSize.x / 2 - ball.width / 2
  ball.y = windowsSize.y / 2 - ball.height / 2

  paddle.x = windowsSize.x - 80
  paddle.y = windowsSize.y / 2 - paddle.height / 2
}
