local vector = {}
vector.__index = vector

function vector.new(x, y, z)
    local self = setmetatable({}, vector)

    self.x = x or 0
    self.y = y or 0
    self.z = z or 0

    return self
end

function vector:cross(v) 
    return vector.new(
        self.y * v.z - self.z * v.y, 
        self.z * v.x - self.x * v.z, 
        self.x * v.y - self.y * v.x
    )
end

function vector:toTable()
    return {x = self.x, y = self.y, z = self.z}
end

function vector:lengthSqr()
    return self.x ^ 2 + self.y ^ 2 + self.z ^ 2
end

function vector:length()
    return math.sqrt(self.x ^ 2 + self.y ^ 2 + self.z ^ 2)
end

function vector:getNormalized()
    local length = self:Length()

    return vector.new(self.x / length, self.y / length, self.z / length)
end

function vector:normalize()
    local length = self:Length()

    self.x = self.x / length
    self.y = self.y / length
    self.z = self.z / length
end

function vector:distance(other)
    return math.sqrt((self.x - other.x) ^ 2 + (self.y - other.y) ^ 2 + (self.z - other.z) ^ 2)
end

function vector:dot(other)
    return self.x * other.x + self.y * other.y + self.z * other.z
end

function vector:rotate(rotation)
    local yaw = math.rad(rotation.yaw)
    local pitch = math.rad(rotation.pitch)
    local roll = math.rad(rotation.roll)

    local x = self.x
    local y = self.y
    local z = self.z

    self.x = x * (math.cos(yaw) * math.cos(pitch)) + y * (math.cos(yaw) * math.sin(pitch) * math.sin(roll) - math.sin(yaw) * math.cos(roll)) + z * (math.cos(yaw) * math.sin(pitch) * math.cos(roll) + math.sin(yaw) * math.sin(roll))
    self.y = x * (math.sin(yaw) * math.cos(pitch)) + y * (math.sin(yaw) * math.sin(pitch) * math.sin(roll) + math.cos(yaw) * math.cos(roll)) + z * (math.sin(yaw) * math.sin(pitch) * math.cos(roll) - math.cos(yaw) * math.sin(roll))
    self.z = x * (-math.sin(pitch)) + y * (math.cos(pitch) * math.sin(roll)) + z * (math.cos(pitch) * math.cos(roll))
end

function vector:set(x, y, z)
    self.x = x
    self.y = y
    self.z = z
end

function vector:__add(other)
    return vector.new(self.x + other.x, self.y + other.y, self.z + other.z)
end

function vector:__sub(other)
    return vector.new(self.x - other.x, self.y - other.y, self.z - other.z)
end

function vector:__mul(other)
    return vector.new(self.x * other.x, self.y * other.y, self.z * other.z)
end

function vector:__div(other)
    return vector.new(self.x / other.x, self.y / other.y, self.z / other.z)
end

function vector:__eq(other)
    return self.x == other.x and self.y == other.y and self.z == other.z
end

function vector:__tostring()
    return string.format("{x = %s, y = %s, z = %s}", self.x, self.y, self.z)
end

function vector:copy()
    return vector.new(self.x, self.y, self.z)
end

return vector