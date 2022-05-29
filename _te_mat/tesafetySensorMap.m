function constraintInd = tesafetySensorMap(teSensorInd)
%


constraintInd = zeros(1,length(teSensorInd));
for i = 1:length(teSensorInd)
    switch teSensorInd(i)
        case 5
            constraintInd(i) = 1;
        case 6
            constraintInd(i) = 2;
        case 7
            constraintInd(i) = 3;
        case 9
            constraintInd(i) = 4;
        case 10
            constraintInd(i) = 5;
        case 12
            constraintInd(i) = 6;
    end
end