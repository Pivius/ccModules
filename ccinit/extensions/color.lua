local color = {}
color.__index = color

function color.new(r, g, b, a)
    local self = setmetatable({}, color)

    self.r = r or 0
    self.g = g or 0
    self.b = b or 0
    self.a = a or 255

    return self
end

function color:toHex()
    return string.format("#%02X%02X%02X", self.r, self.g, self.b)
end

function color:unpack()
    return self.r, self.g, self.b, self.a
end

function color:__tostring()
    return string.format("{r = %s, g = %s, b = %s, a = %s}", self.r, self.g, self.b, self.a)
end

function color:toTable()
    return {r = self.r, g = self.g, b = self.b, a = self.a}
end

function color:copy()
    return color.new(self.r, self.g, self.b, self.a)
end

function color:blend(other, factor)
    return color.new(
        self.r + (other.r - self.r) * factor,
        self.g + (other.g - self.g) * factor,
        self.b + (other.b - self.b) * factor,
        self.a + (other.a - self.a) * factor
    )
end

function color:clamp()
    self.r = math.min(math.max(self.r, 0), 255)
    self.g = math.min(math.max(self.g, 0), 255)
    self.b = math.min(math.max(self.b, 0), 255)
    self.a = math.min(math.max(self.a, 0), 255)
end

function color:darken(factor)
    factor = factor or 0.1

    local r = self.r * (1 - factor)
    local g = self.g * (1 - factor)
    local b = self.b * (1 - factor)

    return Color.new(r, g, b, self.a)
end

function color:lighten(factor)
    factor = factor or 0.1

    local r = self.r + (255 - self.r) * factor
    local g = self.g + (255 - self.g) * factor
    local b = self.b + (255 - self.b) * factor

    return Color.new(r, g, b, self.a)
end

function color:random()
    return color.new(math.random(0, 255), math.random(0, 255), math.random(0, 255), 255)
end

function color:__eq(other)
    return self.r == other.r and self.g == other.g and self.b == other.b and self.a == other.a
end

function color:__add(other)
    return color.new(self.r + other.r, self.g + other.g, self.b + other.b, self.a + other.a)
end

function color:__sub(other)
    return color.new(self.r - other.r, self.g - other.g, self.b - other.b, self.a - other.a)
end

function color:__mul(other)
    return color.new(self.r * other.r, self.g * other.g, self.b * other.b, self.a * other.a)
end

function color:__div(other)
    return color.new(self.r / other.r, self.g / other.g, self.b / other.b, self.a / other.a)
end

return color