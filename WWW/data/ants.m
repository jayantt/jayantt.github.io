%---------- Version 7.0 / Final Version ------------%
% Display size reduce to 250 x 250 pixels (1/16 Mp) as opposed to 500 x 500 (0.25 Mp).
%
% DRAWBACKS:
% 1) Memory inefficient.
% 2) Ants starve to death, but do not return to nest when hungry.

%---------- 1.0 Initialise ----------%

arena=zeros(250,250,3); % Keeps basic coordinates of ants
pher=zeros(250,250,3);  % Keeps track of entire display including food, all pheromones
count_limit=20;         % Decides the birth rate of ants
count=1;
age_limit=10000000000;     % Age limit for ants
hunger_limit=500000000;   % Hunger limit for ants
i_max=5;                % Displays 1 in every `i_max' number of frames to reduce load on processor
i=1;
decay_rate=0.005;       % Decay rate for pheromone
ants=zeros(0,11);        % Ant details: 1)X 2)Y 3)age 4)hunger 5)direction 6)food/exploration/trail-follow 7)steps-from-nest 8)towards-food/nest 9)food trail 10)following which ant 11)step no.
history=zeros(10000,2,0);% Records history of each ant
def=zeros(10000,2);
def(1,1:2)=125;
food_no=5;            % Number of food particles in arena
surround=zeros(3,3,0);
grad=zeros(0);
tracking=zeros(0,2);

% The quantity of food that each ant can carry can be set on line 238.

% How much to contrast between areas of high pheromone against those with
% lower concentration have to be set on both, line 247 and line 250.

%------ 2.0 Obstacle Generation ------%
if randi(2,1,1)==1
    pher(125-randi(124,1,1):125+randi(124,1,1),75+randi(100,1,1),3)=2;
else
    pher(75+randi(100,1,1),125-randi(124,1,1):125+randi(124,1,1),3)=2;
end

%-------- 3.0 Food Generation --------%

for k=1:food_no
    food=randi(246,food_no,2);
    pher((food(k,1)):(food(k,1))+4,(food(k,2)):(food(k,2))+4,3)=1;
end

%----------- 4.0 Iteration -----------%

while (1)
    %-- 4.1 Pheromone Decay --%
    layer1=pher(:,:,1);
    layer2=pher(:,:,2);
    I1=find(layer1>0);
    I2=find(layer2>0);
    layer1(I1)=layer1(I1)-decay_rate;
    layer2(I2)=layer2(I2)-decay_rate;
    pher(:,:,1)=layer1;
    pher(:,:,2)=layer2;
    
    %-- 4.2 Death of Ants --%
    hunger=ants(:,4);
    age=ants(:,3);
    death=find((hunger==hunger_limit)|(age==age_limit));
    for k=(length(death)):-1:1
        ants=[ants(1:death(k)-1,:);ants(death(k)+1:end,:)];
    end
    ants(:,3:4)=ants(:,3:4)+1;
    
    %-- 4.3 Birth of Ants --%
    count=count-1;
    if (count==0)
        count=count_limit;
        ants=[ants;[125 125 0 0 randi(8,1,1)-1 0 1 0 0 0 0]];
        grad=[grad;0];
        history=cat(3,history,def);
        surround=cat(3,surround,zeros(3,3));
    end
    no_ants=length(ants(:,1));
    
    %-- 4.4 Finding Ant Status --%
    for m=1:no_ants
        if (ants(m,3)<age_limit)&(ants(m,4)<hunger_limit)&(ants(m,1)<249)&(ants(m,2)<249)&(ants(m,1)>1)&(ants(m,2)>1)
            if (ants(m,6)==0)&(pher(ants(m,1),ants(m,2),3)>0)
                ants(m,6)=1;
                ants(m,9)=1;
                ants(m,4)=0;
            end
            if (ants(m,8)==0)&(pher(ants(m,1),ants(m,2),3)>0)
                ants(m,8)=1;
                ants(m,4)=0;
            end
            if (ants(m,8)==1)&(ants(m,1)==125)&(ants(m,2)==125)
                ants(m,8)=0;
                ants(m,6)=0;
                ants(m,4)=0;
            end
            if ((ants(m,6)==1)|(ants(m,6)==2))&(ants(m,8)==0)
                if history(ants(m,7)+1,1,m)==0
                    ants(m,6)=0;
                end
            end
            if (pher(ants(m,1),ants(m,2),1)>0)&(ants(m,6)==0)
                useful=find(ants(:,9)==1);
                tracking=zeros(0,2);
                for k=1:length(useful)
                    x=find(history(1:2000,1,useful(k))==ants(m,1));
                    flag=0;
                    for n=1:length(x)
                        if history(x(n),2,useful(k))==ants(m,2)
                            ants(m,6)=2;
                            number=x(n);
                            flag=1;
                        end
                    end
                    if flag==1
                        tracking=[tracking;[useful(k),number]];
                    end
                end
                if ~isempty(tracking)
                    fav_max=0;
                    index=0;
                    for i=1:length(tracking(:,1))
                        ran=randi(length(find(history(:,1,tracking(i,1))>0)),3,1);
                        favour=pher(history(ran(1),1,tracking(i,1)),history(ran(1),2,tracking(i,1)),1)+pher(history(ran(2),1,tracking(i,1)),history(ran(2),2,tracking(i,1)),1)+pher(history(ran(3),1,tracking(i,1)),history(ran(3),2,tracking(i,1)),1);
                        if favour>=fav_max
                            fav_max=favour;
                            index=i;
                        end
                    end
                    ants(m,10)=tracking(index,1);
                    ants(m,11)=tracking(index,2);
                    if ants(m,10)~=m
                        var=length(find(history(:,1,ants(m,10))>0));
                        history(ants(m,7)+1:(ants(m,7)+var-ants(m,11)+1),:,m)=history(ants(m,11):var,:,ants(m,10));
                    else
                        ants(m,7)=ants(m,11)-1;
                    end
                end
            end
        end
    end
    
    %-- 4.5 Movement --%
    
    %- 4.5.1 Following Own Food Trail Back and Forth -%
    for m=1:no_ants
        if (ants(m,3)<age_limit)&(ants(m,4)<hunger_limit)&(ants(m,1)<249)&(ants(m,2)<249)&(ants(m,1)>1)&(ants(m,2)>1)
            if (ants(m,6)==1)|(ants(m,6)==2)
                if ants(m,8)==0
                    ants(m,7)=ants(m,7)+1;
                else
                    ants(m,7)=ants(m,7)-1;
                end
                ants(m,1:2)=history(ants(m,7),:,m);
            end
        end
    end
    
    %- 4.5.2 Random Exploring -%
    move=randi(8,no_ants,1)-1;
    
    for m=1:no_ants
        if (ants(m,3)<age_limit)&(ants(m,4)<hunger_limit)&(ants(m,1)<249)&(ants(m,2)<249)&(ants(m,1)>1)&(ants(m,2)>1)
            if ants(m,6)==0
                if move(m)==ants(m,5)
                    if randi(2,1,1)==1
                        move(m)=rem((move(m)+2),8);
                    else
                        move(m)=rem((move(m)+6),8);
                    end
                end
            end
        end
    end

    %-------- 4.6 Switch Case --------%
    for m=1:no_ants
        if (ants(m,3)<age_limit)&(ants(m,4)<hunger_limit)&(ants(m,1)<249)&(ants(m,2)<249)&(ants(m,1)>1)&(ants(m,2)>1)
            if ants(m,6)==0
                switch(move(m))
                    case{0}
                        if pher(ants(m,1)+1,ants(m,2),3)~=2
                            ants(m,1)=ants(m,1)+1;
                        end
                    case{1}
                        if pher(ants(m,1)+1,ants(m,2)+1,3)~=2
                            ants(m,1:2)=ants(m,1:2)+1;
                        end
                    case{2}
                        if pher(ants(m,1),ants(m,2)+1,3)~=2
                            ants(m,2)=ants(m,2)+1;
                        end
                    case{3}
                        if pher(ants(m,1)-1,ants(m,2)+1,3)~=2
                            ants(m,1)=ants(m,1)-1;
                            ants(m,2)=ants(m,2)+1;
                        end
                    case{4}
                        if pher(ants(m,1)-1,ants(m,2),3)~=2
                            ants(m,1)=ants(m,1)-1;
                        end
                    case{5}
                        if pher(ants(m,1)-1,ants(m,2)-1,3)~=2
                            ants(m,1:2)=ants(m,1:2)-1;
                        end
                    case{6}
                        if pher(ants(m,1),ants(m,2)-1,3)~=2
                            ants(m,2)=ants(m,2)-1;
                        end
                    case{7}
                        if pher(ants(m,1)+1,ants(m,2)-1,3)~=2
                            ants(m,1)=ants(m,1)+1;
                            ants(m,2)=ants(m,2)-1;
                        end
                    case{8}
                        ants(m,1:2)=ants(m,1:2);
                end
            end
        end
    end

    %-- 4.7 Writing History --%
    for m=1:no_ants
        if (ants(m,3)<age_limit)&(ants(m,4)<hunger_limit)&(ants(m,1)<249)&(ants(m,2)<249)&(ants(m,1)>1)&(ants(m,2)>1)
            if ants(m,6)==0
                ants(m,7)=ants(m,7)+1;
                history(ants(m,7),:,m)=ants(m,1:2);
            end
        end
    end
        
    %-- 4.8 Update Arena and Pheromones --%
    for m=1:no_ants
        if (ants(m,3)<age_limit)&(ants(m,4)<hunger_limit)&(ants(m,1)<249)&(ants(m,2)<249)&(ants(m,1)>1)&(ants(m,2)>1)
            arena=zeros(250,250,3);
            arena(ants(m,1),ants(m,2),1:3)=arena(ants(m,1),ants(m,2),1:3)+1;
            if ants(m,6)==0
                pher(ants(m,1),ants(m,2),2)=pher(ants(m,1),ants(m,2),2)+1;
            elseif (ants(m,6)==1)|((ants(m,6)==2)&(ants(m,8)==1))
                pher(ants(m,1),ants(m,2),1)=pher(ants(m,1),ants(m,2),1)+1;
            end
            if pher(ants(m,1),ants(m,2),3)>0
                pher(ants(m,1),ants(m,2),3)=pher(ants(m,1),ants(m,2),3)-0.5; % Decides the amount of food each ant can carry.
            end
        end
    end
    
    %-- 4.9 Display --%
    i=i-1;
    junk=ones(250,250,3);
    if max(max(pher(:,:,2)))>1
        junk(:,:,2)=4./(max(max(max(pher(:,:,1:2))))); % Decides how much to contrast between areas of high pheromone against those with lower concentration.
    end
    if max(max(pher(:,:,1)))>1
        junk(:,:,1)=4./(max(max(max(pher(:,:,1:2))))); % Decides how much to contrast between areas of high pheromone against those with lower concentration.
    end
    imshow(pher.*junk);
    if (i==0)
        drawnow;
        i=i_max;
    end
end