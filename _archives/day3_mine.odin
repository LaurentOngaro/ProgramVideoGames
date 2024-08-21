// Program Video Games first mini-course
// Day 3: Simple collisions, multiple moving objects
// personnal version

package main

import rl "vendor:raylib"

main :: proc() {
  fpsLimit: i32 = 60
  screenSize: rl.Vector2 = {1280, 720}

  paddleSize: rl.Vector2 = {20, 100}
  paddlePos: rl.Vector2 = {10, 10}
  paddleSpeed: f32 = 10.0

  ballSize: rl.Vector2 = {20, 20}
  ballPos: rl.Vector2 = {100, 10}
  ballSpeed: f32 = 10.0
  ballDirection: rl.Vector2 = {1, 1}

  rl.InitWindow(i32(screenSize.x), i32(screenSize.y), "Pong")
  rl.SetTargetFPS(fpsLimit)

  for !rl.WindowShouldClose() {
    if rl.IsKeyDown(rl.KeyboardKey.A) {
      paddlePos.x -= paddleSpeed // X -= Y is X = X - Y
    } else if rl.IsKeyDown(rl.KeyboardKey.D) {
      paddlePos.x += paddleSpeed
    }
    if rl.IsKeyDown(rl.KeyboardKey.W) {
      paddlePos.y -= paddleSpeed // X -= Y is X = X - Y
    } else if rl.IsKeyDown(rl.KeyboardKey.S) {
      paddlePos.y += paddleSpeed
    }
    nextBallPos: rl.Vector2 = ballPos + ballSpeed * ballDirection
    if nextBallPos.x > screenSize.x || nextBallPos.x < 0 {
      ballDirection.x *= -1
    }
    if nextBallPos.y > screenSize.y || nextBallPos.y < 0 {
      ballDirection.y *= -1
    }
    paddleRect: rl.Rectangle = {paddlePos.x, paddlePos.y, paddleSize.x, paddleSize.y}
    nextBallRect: rl.Rectangle = {nextBallPos.x, nextBallPos.y, ballSize.x, ballSize.y}
    if rl.CheckCollisionRecs(nextBallRect, paddleRect) {
      ballDirection.x *= -1
    }
    ballPos += ballSpeed * ballDirection

    rl.BeginDrawing()
    rl.ClearBackground(rl.BLACK)
    rl.DrawText("This is Pong", 300, 2, 20, rl.BLUE)
    rl.DrawRectangleRec(paddleRect, rl.WHITE)
    rl.DrawRectangleRec(nextBallRect, rl.RED)
    rl.EndDrawing()
  }
}
