const rl = @import("raylib");

pub fn main() void {
    const screenWidth = 800;
    const screenHeight = 450;
    const FPS = 60;

    rl.initWindow(screenWidth, screenHeight, "zigland invader");

    defer rl.closeWindow(); // runs at end of scope here it is the main function itself usefull incas eof something like memory leak when there a early return check out errordefer

    rl.setTargetFPS(FPS);

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        rl.clearBackground(rl.Color.black);
        rl.drawText("Welcome to Zigland Invader!", 190, 200, 20, rl.Color.green);
        rl.endDrawing();
    }
}
