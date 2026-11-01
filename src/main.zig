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

const Bullet = struct {
    width: f32,
    height: f32,
    speed: f32,
    x: f32,
    y: f32,
    active: bool,

    pub fn init(x: f32, y: f32, width: f32, height: f32, speed: f32, active: bool) @This() {
        return .{
            .x = x,
            .y = y,
            .width = width,
            .height = height,
            .speed = speed,
            .active = active,
        };
    }

    pub fn update(self: *@This()) void {
        if (self.active) {
            self.y -= self.speed;
            if (self.y + self.height < 0) {
                self.active = false;
            }
        }
    }

    pub fn draw(self: @This()) void {
        if (self.active) {
            rl.drawRectangle(
                @intFromFloat(self.x),
                @intFromFloat(self.y),
                @intFromFloat(self.width),
                @intFromFloat(self.height),
                rl.Color.red,
            );
        }
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

    const bulletWidth = 5;
    const bulletHeight = 20;
    const bulletSpeed = 10.0;
    const maxBullets = 10;
    var bullets: [maxBullets]Bullet = undefined;

    for (&bullets) |*bullet| {
        bullet.* = Bullet.init(0, 0, @as(f32, @floatFromInt(bulletWidth)), @as(f32, @floatFromInt(bulletHeight)), bulletSpeed, false);
    }

    defer rl.closeWindow(); // runs at end of scope here it is the main function itself usefull incas eof something like memory leak when there a early return check out errordefer

    rl.setTargetFPS(FPS);

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.black);

        if (rl.isKeyDown(rl.KeyboardKey.space)) {
            for (&bullets) |*bullet| {
                if (bullet.active == false) {
                    bullet.x = p.position_x + p.width / 2 - bullet.width / 2;
                    bullet.y = p.position_y;
                    bullet.active = true;
                    break;
                }
            }
        }

        // update logic
        p.update();
        for (&bullets) |*bullet| {
            bullet.update();
        }

        // draw logic
        for (&bullets) |*bullet| {
            bullet.draw();
        }
        p.draw();
    }
}
