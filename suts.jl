# bytecount

function byte_count(bytes::Integer, si::Bool = true)
    unit = si ? 1000 : 1024
    if bytes < unit
        return string(bytes) * "B"
    end
    exp = floor(Int, log(bytes) / log(unit))
    pre = (si ? "kMGTPE" : "KMGTPE")[exp] * (si ? "" : "i")
    @sprintf("%.1f %sB", bytes / (unit^exp), pre)
end

# BMI numeric + classification

function bmi(height::Integer, weight::Integer)
    if height < 0 || weight < 0
        throw(DomainError("Height or Weight cannot be negative."))
    end
    heigh_meters = height / 100 # Convert height from cm to meters
    bmivalue = round(weight / heigh_meters^2, digits = 1) # official standard expects 1 decimal after the comma
    return (bmivalue)
end

function bmi_tostring(height::Integer, weight::Integer)
    bmivalue = bmi(height,weight)
    @sprintf "%.1f" bmivalue
end

function bmi_classification(height::Integer, weight::Integer)
    bmivalue = bmi(height,weight)
    class = ""
    if bmivalue < 0
        throw(DomainError(bmivalue, "BMI was negative. Check your inputs: $(height) cm; $(weight) kg"))
    elseif bmivalue < 18.5
        class = "Underweight"
    elseif bmivalue < 23
        class = "Normal"
    elseif bmivalue < 25
        class = "Overweight"
    elseif bmivalue < 30
        class = "Obese"
    else class = "Severely obese"
    end
    return class
end

# Julia Date

using Dates

datesut = (year, month, day) -> Date(year, month, day)
