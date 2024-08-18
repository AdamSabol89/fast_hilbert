const std = @import("std");
const testing = std.testing;
const print = std.debug.print;

const LUT_3 = [_]u8{
    64,  1,   206, 79,  16,  211, 84,  21,  131, 2,   205, 140, 81,  82,  151, 22,  4,   199, 8,   203, 158,
    157, 88,  25,  69,  70,  73,  74,  31,  220, 155, 26,  186, 185, 182, 181, 32,  227, 100, 37,  59,  248,
    55,  244, 97,  98,  167, 38,  124, 61,  242, 115, 174, 173, 104, 41,  191, 62,  241, 176, 47,  236, 171,
    42,  0,   195, 68,  5,   250, 123, 60,  255, 65,  66,  135, 6,   249, 184, 125, 126, 142, 141, 72,  9,
    246, 119, 178, 177, 15,  204, 139, 10,  245, 180, 51,  240, 80,  17,  222, 95,  96,  33,  238, 111, 147,
    18,  221, 156, 163, 34,  237, 172, 20,  215, 24,  219, 36,  231, 40,  235, 85,  86,  89,  90,  101, 102,
    105, 106, 170, 169, 166, 165, 154, 153, 150, 149, 43,  232, 39,  228, 27,  216, 23,  212, 108, 45,  226,
    99,  92,  29,  210, 83,  175, 46,  225, 160, 159, 30,  209, 144, 48,  243, 116, 53,  202, 75,  12,  207,
    113, 114, 183, 54,  201, 136, 77,  78,  190, 189, 120, 57,  198, 71,  130, 129, 63,  252, 187, 58,  197,
    132, 3,   192, 234, 107, 44,  239, 112, 49,  254, 127, 233, 168, 109, 110, 179, 50,  253, 188, 230, 103,
    162, 161, 52,  247, 56,  251, 229, 164, 35,  224, 117, 118, 121, 122, 218, 91,  28,  223, 138, 137, 134,
    133, 217, 152, 93,  94,  11,  200, 7,   196, 214, 87,  146, 145, 76,  13,  194, 67,  213, 148, 19,  208,
    143, 14,  193, 128,
};

pub fn toHilbert(x: usize, y: usize, order: u8) usize {
    const coor_bits: u32 = @sizeOf(usize) << 3;
    const one: u32 = 1;
    const useless_bits: u32 = @clz(x | y) & ~one;

    //print("wtf is happening: useless_bits: {d}, coor_bites {d}\n", .{ useless_bits, coor_bits });
    //TODO: pottentialy keep everything as u8 to avoid truncate here
    var lowest_order: u8 = @truncate(coor_bits - useless_bits);
    lowest_order = lowest_order + (order & 1);

    var result: usize = 0;
    var state: u8 = 0;

    var shift_factor: i8 = @intCast(lowest_order);
    //need to redo this part
    shift_factor = shift_factor - 3;

    //@compileLog(@TypeOf(shift_factor));
    // TODO: need to something like if @SizeOf(usize) == 64 shift_factor = u6. should be doable with comptime logic
    //care full moved shift factor to u6 so maybe integer overflow

    while (shift_factor > 0) {
        const i6_shift_factor: i6 = @truncate(shift_factor);
        const u6_shift_factor: u6 = @bitCast(i6_shift_factor);

        const x_in = (x >> u6_shift_factor & 7) << 3;
        const y_in = (y >> u6_shift_factor & 7);

        const index = (x_in | y_in | state);
        var r = LUT_3[index];
        state = r & 0b11000000;

        r = r & 63;
        var hhh: usize = @intCast(r);
        hhh <<= (u6_shift_factor << 1);

        result |= hhh;
        //print("x_in, {d}, y_in {d}, index: {d}, r {d}, state {d},  hhh: {d}, result: {d}\n", .{ x_in, y_in, index, r, state, hhh, result });

        shift_factor -= 3;
    }

    shift_factor *= -1;
    const i6_shift_factor: i6 = @truncate(shift_factor);
    const u6_shift_factor: u6 = @bitCast(i6_shift_factor);

    const x_in = ((x << u6_shift_factor) & 7) << 3;
    const y_in = (y << u6_shift_factor) & 7;

    const index = (x_in | y_in | state);
    var r = LUT_3[index];
    r = r & 63;

    var hhh: usize = @intCast(r);
    hhh >>= @intCast(u6_shift_factor << 1);

    print("hilbert {d}\n", .{result | hhh});
    return result | hhh;
}

test "toHilbert" {
    const x: usize = 1231;
    const y: usize = 1278;
    const order: u8 = 32;

    _ = toHilbert(x, y, order);
}
