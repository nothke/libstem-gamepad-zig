## Original readme:

Gamepad provides a low-level interface for USB game controller input. Each element on an attached game controller is mapped to zero or more buttons and zero or more axes. Buttons are binary controls; axes are continuous values ranging from -1.0f to 1.0f. The presence and ordering of elements depends on the platform and driver.

Typical usage: Register a callback to notify you when a new device is attached with Gamepad_deviceAttachFunc(), then call Gamepad_init() and Gamepad_detectDevices(). Your callback will be called once per connected game controller. Also register callbacks for button and axis events with Gamepad_buttonDownFunc(), Gamepad_buttonUpFunc(), and Gamepad_axisMoveFunc(). Call Gamepad_processEvents() every frame, and Gamepad_detectDevices() occasionally to be notified of new devices that were plugged in after your Gamepad_init() call. If you're interested in knowing when a device was disconnected, you can also call Gamepad_deviceRemoveFunc() to be notified of this.

See Gamepad.h for more details.

#### This fork adds zig build and zig package manager support:

## Building

Apart from `make`, you can also now build it with `zig build`

## Using it in a zig project

Just call

```bash
zig fetch --save git+https://github.com/nothke/libstem-gamepad-zig.git
```

Then in your build.zig add:

```zig
const gamepad_dep = b.dependency("libstem_gamepad", .{ .target = target, .optimize = optimize });
exe.linkLibrary(gamepad_dep.artifact("stem_gamepad"));
```

Finally you can use it by including it like:

```zig
const c = @cImport({
    @cInclude("Gamepad.h");
});

pub fn main() !void {
    c.Gamepad_init();
    // ...
}
```