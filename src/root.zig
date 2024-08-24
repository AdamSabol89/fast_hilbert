const LUT_3_REV = [_]u8{
    64,  1,   9,   136, 16,  88,  89,  209, 18,  90,  91,  211, 139, 202, 194, 67,  4,   76,  77,  197, 70,  7,
    15,  142, 86,  23,  31,  158, 221, 149, 148, 28,  36,  108, 109, 229, 102, 39,  47,  174, 118, 55,  63,  190,
    253, 181, 180, 60,  187, 250, 242, 115, 235, 163, 162, 42,  233, 161, 160, 40,  112, 49,  57,  184, 0,   72,
    73,  193, 66,  3,   11,  138, 82,  19,  27,  154, 217, 145, 144, 24,  96,  33,  41,  168, 48,  120, 121, 241,
    50,  122, 123, 243, 171, 234, 226, 99,  100, 37,  45,  172, 52,  124, 125, 245, 54,  126, 127, 247, 175, 238,
    230, 103, 223, 151, 150, 30,  157, 220, 212, 85,  141, 204, 196, 69,  6,   78,  79,  199, 255, 183, 182, 62,
    189, 252, 244, 117, 173, 236, 228, 101, 38,  110, 111, 231, 159, 222, 214, 87,  207, 135, 134, 14,  205, 133,
    132, 12,  84,  21,  29,  156, 155, 218, 210, 83,  203, 131, 130, 10,  201, 129, 128, 8,   80,  17,  25,  152,
    32,  104, 105, 225, 98,  35,  43,  170, 114, 51,  59,  186, 249, 177, 176, 56,  191, 254, 246, 119, 239, 167,
    166, 46,  237, 165, 164, 44,  116, 53,  61,  188, 251, 179, 178, 58,  185, 248, 240, 113, 169, 232, 224, 97,
    34,  106, 107, 227, 219, 147, 146, 26,  153, 216, 208, 81,  137, 200, 192, 65,  2,   74,  75,  195, 68,  5,
    13,  140, 20,  92,  93,  213, 22,  94,  95,  215, 143, 206, 198, 71,
};

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
    var result: usize = 0;
    var state: u8 = 0;

    const coor_bits: u8 = @sizeOf(usize) << 3;
    const one: u8 = 1;
    const useless_bits: u8 = @clz(x | y) & ~one;
    const lowest_order = (coor_bits - useless_bits) + (order & 1);

    var shift_factor: i8 = @intCast(lowest_order);
    shift_factor -= 3;

    while (shift_factor > 0) : (shift_factor -= 3) {
        const i6_shift_factor: i6 = @truncate(shift_factor);
        const u6_shift_factor: u6 = @bitCast(i6_shift_factor);

        const x_in = (x >> u6_shift_factor & 7) << 3;
        const y_in = (y >> u6_shift_factor & 7);

        var r = LUT_3[x_in | y_in | state];
        state = r & 0b11000000;
        r = r & 63;

        const hhh: usize = @intCast(r);
        result |= (hhh << (u6_shift_factor << 1));
    }

    shift_factor *= -1;
    const i6_shift_factor: i6 = @truncate(shift_factor);
    const u6_shift_factor: u6 = @bitCast(i6_shift_factor);

    const x_in = ((x << u6_shift_factor) & 7) << 3;
    const y_in = (y << u6_shift_factor) & 7;

    var r = LUT_3[x_in | y_in | state];
    r = r & 63;

    var hhh: usize = @intCast(r);
    hhh >>= @intCast(u6_shift_factor << 1);
    return result | hhh;
}

pub fn fromHilbert(hilbert_index: usize, order: u8) struct { x: usize, y: usize } {
    const coor_bits: u8 = @sizeOf(usize) << 3;
    const one: u8 = 1;
    const useless_bits: u8 = (@clz(hilbert_index)) & ~one;
    const lowest_order: u8 = (coor_bits - useless_bits) + (order & 1);

    var state: u8 = 0;
    var shift_factor: i8 = @intCast(lowest_order);
    shift_factor -= 3;

    var x_result: usize = 0;
    var y_result: usize = 0;

    while (shift_factor > 0) : (shift_factor -= 3) {
        const i6_shift_factor: i6 = @truncate(shift_factor);
        const u6_shift_factor: u6 = @bitCast(i6_shift_factor);

        const hil_modified: u8 = @intCast((hilbert_index >> (u6_shift_factor << 1)) & 63);

        const r = LUT_3_REV[state | hil_modified];
        state = r & 0b11000000;

        var xxx: usize = @intCast(r);
        xxx >>= 3;
        xxx &= 7;

        var yyy: usize = @intCast(r);
        yyy &= 7;

        x_result |= (xxx << u6_shift_factor);
        y_result |= (yyy << u6_shift_factor);
    }
    shift_factor *= -1;

    const i6_shift_factor: i6 = @truncate(shift_factor);
    const u6_shift_factor: u6 = @bitCast(i6_shift_factor);
    const hil_modified: u8 = @intCast((hilbert_index << (u6_shift_factor << 1)) & 63);

    const r = LUT_3_REV[state | hil_modified];

    var xxx: usize = @intCast(r);
    xxx >>= 3;
    xxx &= 7;

    var yyy: usize = @intCast(r);
    yyy &= 7;

    x_result |= (xxx >> u6_shift_factor);
    y_result |= (yyy >> u6_shift_factor);

    return .{ .x = x_result, .y = y_result };
}

test "fromHilbert" {
    const std = @import("std");
    const print = std.debug.print;
    const hil_index: usize = 100;
    const order: u8 = 5;

    const res = fromHilbert(hil_index, order);
    print("x {d}, y {d}\n", .{ res.x, res.y });
}

test "toHilbert" {
    const std = @import("std");
    const print = std.debug.print;
    const x: usize = 14;
    const y: usize = 4;
    const order: u8 = 5;

    const result = toHilbert(x, y, order);
    print("hilbert {d}\n", .{result});
}
