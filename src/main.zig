const rl = @import("raylib");

const Rectangle = struct {
    x: f32,
    y: f32,
    width: f32,
    height: f32,

    pub fn intersects(self: Rectangle, other: Rectangle) bool {
        return self.x < other.x + other.width and
            self.x + self.width > other.x and
            self.y < other.y + other.height and
            self.y + self.height > other.y;
    }
};

const GameConfig = struct {
    screenWidth: i32,
    screenHeight: i32,
    FPS: i32,
    playerWidth: f32,
    playerHeight: f32,
    playerStartY: i32,
    bulletWidth: f32,
    bulletHeight: f32,
    sheildWidth: f32,
    sheildHeight: f32,
    sheildStartY: f32,
    sheildStartX: f32,
    sheildSpacing: f32,
    invaderWidth: f32,
    invaderHeight: f32,
    invaderSpacingX: f32,
    invaderSpacingY: f32,
    invaderStartY: f32,
    invaderStartX: f32,
    invaderSpacing: f32,
};

const player = struct {
    position_x: f32,
    position_y: f32,
    width: f32,
    height: f32,
    speed: f32,

    pub fn init(position_x: f32, position_y: f32, width: f32, height: f32, speed: f32) @This() {
        return .{
            .position_x = position_x,
            .position_y = position_y,
            .width = width,
            .height = height,
            .speed = speed,
        };
    }

    pub fn update(self: *@This()) void {
        if (rl.isKeyDown(rl.KeyboardKey.right)) {
            self.position_x += self.speed;
        }

        if (rl.isKeyDown(rl.KeyboardKey.left)) {
            self.position_x -= self.speed;
        }

        if (self.position_x < 0) {
            self.position_x = 0;
        }

        if (self.position_x + self.width > @as(f32, @floatFromInt(rl.getScreenWidth()))) {
            self.position_x = @as(f32, @floatFromInt(rl.getScreenWidth())) - self.width;
        }
    }

    pub fn getRectangle(self: @This()) Rectangle {
        return .{
            .x = self.position_x,
            .y = self.position_y,
            .width = self.width,
            .height = self.height,
        };
    }

    pub fn draw(self: @This()) void {
        rl.drawRectangle(
            @intFromFloat(self.position_x),
            @intFromFloat(self.position_y),
            @intFromFloat(self.width),
            @intFromFloat(self.height),
            rl.Color.blue,
        );
    }
};

pub fn main() void {
    const screenWidth = 800;
    const screenHeight = 450;
    const FPS = 60;

    rl.initWindow(screenWidth, screenHeight, "zigland invader");

    const playerWidth = 50;
    const playerHeight = 30;

    var p = player.init(
        @as(f32, @floatFromInt(screenWidth - playerWidth)) / 2.0,
        @as(f32, @floatFromInt(screenHeight - playerHeight - 10)),
        @as(f32, @floatFromInt(playerWidth)),
        @as(f32, @floatFromInt(playerHeight)),
        5.0,
    );

    defer rl.closeWindow(); // runs at end of scope here it is the main function itself usefull incas eof something like memory leak when there a early return check out errordefer

    rl.setTargetFPS(FPS);

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();
        rl.clearBackground(rl.Color.black);
        p.update();
        p.draw();
        rl.drawText("Welcome to Zigland Invader!", 190, 200, 20, rl.Color.green);
    }
}
