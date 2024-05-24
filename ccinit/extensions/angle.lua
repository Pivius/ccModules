local angle = {}
angle.__index = angle

function angle.new(yaw, pitch)
    local self = setmetatable({}, angle)

    self.yaw = yaw or 0
    self.pitch = pitch or 0

    return self
end

function angle:forward()
    local yaw = math.rad(self.yaw)
    local pitch = math.rad(self.pitch)

    return Vector.new(
        -math.sin(yaw) * math.cos(pitch),
        -math.sin(pitch),
        math.cos(yaw) * math.cos(pitch)
    )
end

function angle:right()
    local yaw = math.rad(self.yaw)

    return Vector.new(
        math.cos(yaw),
        0,
        math.sin(yaw)
    )
end

function angle:up()
    local yaw = math.rad(self.yaw)
    local pitch = math.rad(self.pitch)

    return Vector.new(
        -math.sin(yaw) * math.sin(pitch),
        math.cos(pitch),
        math.cos(yaw) * math.sin(pitch)
    )
end

function angle:isEqualTolerance(other, tolerance)
    return math.abs(self.yaw - other.yaw) <= tolerance and math.abs(self.pitch - other.pitch) <= tolerance
end

function angle:normalize()
    self.yaw = self.yaw % 360
    self.pitch = self.pitch % 360
end

function angle:rotateAroundAxis(axis, rotation)
    local yaw = math.rad(self.yaw)
    local pitch = math.rad(self.pitch)
    local roll = math.rad(self.roll)

    local sin = math.sin(rotation)
    local cos = math.cos(rotation)

    local x = axis.x
    local y = axis.y
    local z = axis.z

    local x2 = x * x
    local y2 = y * y
    local z2 = z * z

    local m00 = x2 + (y2 + z2) * cos
    local m01 = x * y * (1 - cos) - z * sin
    local m02 = x * z * (1 - cos) + y * sin

    local m10 = x * y * (1 - cos) + z * sin
    local m11 = y2 + (x2 + z2) * cos
    local m12 = y * z * (1 - cos) - x * sin

    local m20 = x * z * (1 - cos) - y * sin
    local m21 = y * z * (1 - cos) + x * sin
    local m22 = z2 + (x2 + y2) * cos

    local x_ = m00 * math.cos(yaw) + m01 * math.sin(yaw) + m02 * math.cos(pitch)
    local y_ = m10 * math.cos(yaw) + m11 * math.sin(yaw) + m12 * math.cos(pitch)
    local z_ = m20 * math.cos(yaw) + m21 * math.sin(yaw) + m22 * math.cos(pitch)

    self.yaw = math.atan2(y_, x_)
    self.pitch = math.asin(z_)
end

function angle:set(yaw, pitch)
    self.yaw = yaw
    self.pitch = pitch
end

function angle:toTable()
    return {yaw = self.yaw, pitch = self.pitch}
end

function angle:toVector()
    return Vector.new(self.yaw, self.pitch, 0)
end

function angle:__tostring()
    return string.format("{yaw = %s, pitch = %s}", self.yaw, self.pitch)
end

function angle:__add(other)
    return angle.new(self.yaw + other.yaw, self.pitch + other.pitch)
end

function angle:__sub(other)
    return angle.new(self.yaw - other.yaw, self.pitch - other.pitch)
end

function angle:__mul(other)
    return angle.new(self.yaw * other.yaw, self.pitch * other.pitch)
end

function angle:__div(other)
    return angle.new(self.yaw / other.yaw, self.pitch / other.pitch)
end