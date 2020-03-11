function result=mysvmtest(TestSet,models,numClasses)
result = zeros(length(TestSet(:,1)),1);
for j=1:size(TestSet,1)
    for k=1:numClasses
        if(svmclassify(models(k),TestSet(j,:))) 
            break;
        end
    end
    result(j) = k;
end