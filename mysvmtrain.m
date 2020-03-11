function [models numClasses]=mysvmtrain(TrainingSet,GroupTrain)
u=unique(GroupTrain);
numClasses=length(u);
%build models
for k=1:numClasses
    %Vectorized statement that binarizes Group
    %where 1 is the current class and 0 is all other classes
    G1vAll=(GroupTrain==u(k));
    models(k) = svmtrain(TrainingSet,G1vAll);
end