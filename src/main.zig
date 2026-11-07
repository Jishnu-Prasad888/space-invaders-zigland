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

    pub fn getRectangle(self: @This()) Rectangle {
        return .{
            .x = self.x,
            .y = self.y,
            .width = self.width,
            .height = self.height,
        };
    }
};

const Invader = struct {
    width: f32,
    height: f32,
    x: f32,
    y: f32,
    alive: bool,

    pub fn init(x: f32, y: f32, width: f32, height: f32) @This() {
        return .{
            .x = x,
            .y = y,
            .width = width,
            .height = height,
            .alive = true,
        };
    }

    pub fn update(self: *@This(), dx: f32, dy: f32) void {
        if (self.alive) {
            self.x += dx;
            self.y += dy;
        }
    }

    pub fn draw(self: @This()) void {
        if (self.alive) {
            rl.drawRectangle(
                @intFromFloat(self.x),
                @intFromFloat(self.y),
                @intFromFloat(self.width),
                @intFromFloat(self.height),
                rl.Color.green,
            );
        }
    }

    pub fn getRectangle(self: @This()) Rectangle {
        return .{
            .x = self.x,
            .y = self.y,
            .width = self.width,
            .height = self.height,
        };
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
    const bulletHeight = 5;
    const bulletSpeed = 10.0;
    const maxBullets = 10;
    var bullets: [maxBullets]Bullet = undefined;

    for (&bullets) |*bullet| {
        bullet.* = Bullet.init(0, 0, @as(f32, @floatFromInt(bulletWidth)), @as(f32, @floatFromInt(bulletHeight)), bulletSpeed, false);
    }

    const invaderWidth = 40;
    const invaderHeight = 30;
    const invaderSpacingX = 10;
    const invaderSpacingY = 10;
    const invaderRows = 5;
    const invaderCols = 10;
    const invaderStartY = 50;
    const invaderStartX = 150;
    const invaderMoveDelay = 0.5; // seconds
    const invaderSpeed: f32 = 10.0;
    var invaderDirection: f32 = 1;
    var move_timer: f32 = 0; // 1 for right, -1 for left
    const invaderDropHeight: f32 = 7.0;
    var invaders: [invaderRows][invaderCols]Invader = undefined;

    for (&invaders, 0..) |*row, rowIndex| {
        for (row, 0..) |*invader, colIndex| {
            const x = @as(f32, @floatFromInt(invaderStartX + colIndex * (invaderWidth + invaderSpacingX)));
            const y = @as(f32, @floatFromInt(invaderStartY + rowIndex * (invaderHeight + invaderSpacingY)));
            invader.* = Invader.init(
                x,
                y,
                @as(f32, @floatFromInt(invaderWidth)),
                @as(f32, @floatFromInt(invaderHeight)),
            );
        }
    }

    defer rl.closeWindow(); // runs at end of scope here it is the main function itself usefull incas eof something like memory leak when there a early return check out errordefer

    rl.setTargetFPS(FPS);

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.black);

        if (rl.isKeyPressed(rl.KeyboardKey.space)) {
            for (&bullets) |*bullet| {
                if (bullet.active == false) {
                    bullet.x = p.position_x + p.width / 2 - bullet.width / 2;
                    bullet.y = p.position_y;
                    bullet.active = true;
                    break;
                }
            }
        }

        for (&bullets) |*bullet| {
            if (bullet.active) {
                for (&invaders) |*row| {
                    for (row) |*invader| {
                        if (invader.alive and bullet.getRectangle().intersects(invader.getRectangle())) {
                            invader.alive = false;
                            bullet.active = false;
                            break;
                        }
                    }
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

        move_timer += 1;
        if (move_timer >= invaderMoveDelay * @as(f32, @floatFromInt(FPS))) {
            move_timer = 0;

            var invaderHitEdge = false;
            for (&invaders) |*row| {
                for (row) |*invader| {
                    if (invader.alive) {
                        if (invader.x <= 0 or invader.x + invader.width >= @as(f32, @floatFromInt(screenWidth))) {
                            invaderHitEdge = true;
                            break;
                        }
                    }

                    if (invaderHitEdge) break;
                }
            }

            if (invaderHitEdge) {
                invaderDirection *= -1;

                for (&invaders) |*row| {
                    for (row) |*invader| {
                        invader.update(0, invaderDropHeight);
                    }
                }
            }
            for (&invaders) |*row| {
                for (row) |*invader| {
                    invader.update(invaderSpeed * invaderDirection, 0);
                }
            }
        }

        for (&invaders) |*row| {
            for (row) |*invader| {
                invader.update(0, 0);
                invader.draw();
            }
        }
        p.draw();
    }
}
