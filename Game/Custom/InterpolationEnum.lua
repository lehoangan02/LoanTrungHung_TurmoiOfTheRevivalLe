local InterpolationTypeEnum = {
    Jump = 0,
    Linear = 1,
    EaseCubic = 2,
    EaseElastic = 3,
    EaseBack = 4,
}

local InterpolationDirection = {
    In = 0,
    Out = 1,
    InOut = 2,
}

return {
    InterpolationTypeEnum = InterpolationTypeEnum,
    InterpolationDirection = InterpolationDirection
}
