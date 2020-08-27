sim = ScorSimInit;
ScorSimPatch(sim);

%% Random moves (linear joint)
iter = 0;
ScorSimSetSpeed(sim,100);
%while iter < 10
    iter = iter + 1;
    ScorSimSetBSEPR(sim,rand(1,5),'MoveType','LinearTask');
    [~,~,cData(iter)] = ScorSimWaitForMove(sim,'CollectData','on');
%end

%% Combine data and plot
tXYZPR = [];
tBSEPR = [];
for i = 1:numel(cData)
    if i > 1
        tX_0 = tXYZPR(end,1);
        tB_0 = tBSEPR(end,1);
    else
        tX_0 = 0;
        tB_0 = 0;
    end
    
    tXYZPR = [tXYZPR; cData(i).tXYZPR + ...
        [repmat(tX_0,size(cData(i).tXYZPR,1),1),...
         zeros(size(cData(i).tXYZPR,1),5)]];
    tBSEPR = [tBSEPR; cData(i).tBSEPR + ...
        [repmat(tB_0,size(cData(i).tBSEPR,1),1),...
         zeros(size(cData(i).tBSEPR,1),5)]];
end

figure
axes
hold on
t = tXYZPR(:,1);
for i = 2:6
    q = tXYZPR(:,i);
    plot(t,q,'LineWidth',1.5);
end

figure
axes
hold on
t = tBSEPR(:,1);
for i = 2:6
    q = tBSEPR(:,i);
    plot(t,q,'LineWidth',1.5);
end