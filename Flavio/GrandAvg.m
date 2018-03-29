function [ average ] = GrandAvg( signal,index )
%Compute grand Average of a given series of event
leng = min(diff([1;index]));

selected =  signal(1:index(1),:);
average = selected(1:leng,:);

for i = 1 : length(index)-1
    selected = signal(index(i):index(i+1),:);
    average = average + selected(1:leng,:);
end

average = average / length(index);

end

