// Program Video Games first mini-course
// Day 2: Getting Started with Raylib

package main

// import "core:fmt"
import rl "vendor:raylib"

main :: proc() {
  posX: i32 = 100
  posY: i32 = 100

  rl.InitWindow(1280, 720, "Pong")
  rl.SetTargetFPS(60)

  for !rl.WindowShouldClose() {
    if rl.IsKeyDown(rl.KeyboardKey.A) {
      posX -= 10 // X -= Y is X = X - Y
    } else if rl.IsKeyDown(rl.KeyboardKey.D) {
      posX += 10
    }
    if rl.IsKeyDown(rl.KeyboardKey.W) {
      posY -= 10 // X -= Y is X = X - Y
    } else if rl.IsKeyDown(rl.KeyboardKey.S) {
      posY += 10
    }

    rl.BeginDrawing()
    rl.ClearBackground(rl.BLACK)
    rl.DrawText("Hello, Odin!", 10, 10, 20, rl.BLUE)
    rl.DrawRectangle(posX, posY, 180, 30, rl.WHITE)
    rl.EndDrawing()
  }
}
